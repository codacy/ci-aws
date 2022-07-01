#!/usr/bin/env python3
"""Check if a given workflow for a project/branch can run"""

from argparse import ArgumentParser
from http.client import HTTPSConnection
import json
import time
import sys

class CircleCIApi:
    """Wrapper for some CircleCI v2 API endpoints"""
    def __init__(self, token, debug=False):
        self.token = token
        self.debug = debug
        self.base_path = "/api/v2"
        self.hostname = "circleci.com"

    def get_items(self, path):
        """Call a given CircleCI API v2 path and return a list of the items in the response"""
        connection = HTTPSConnection(self.hostname)
        connection.request("GET", f"{self.base_path}/{path}", headers={"Circle-Token": f"{self.token}"})
        response = connection.getresponse().read().decode("utf-8")
        if self.debug:
            print(f"\nResponse output: \n{response}\n")
        return json.loads(response)["items"]

    def pipelines(self, project_slug):
        """
        get pipelines for this project slug
        see https://circleci.com/docs/api/v2/index.html#operation/listPipelines
        """
        if self.debug:
            print(f"- Getting pipelines for project {project_slug}")
        return self.get_items("project/%s/pipeline"%project_slug)

    def workflows(self, pipeline_id):
        """
        Get pipeline workflows
        see https://circleci.com/docs/api/v2/index.html#operation/listWorkflowsByPipelineId
        """
        if self.debug:
            print(f"- Getting workflows for pipeline {pipeline_id}")
        return self.get_items("pipeline/%s/workflow"%pipeline_id)

    def jobs(self, workflow_id):
        """
        get running jobs for this workflow
        see https://circleci.com/docs/api/v2/index.html#operation/listWorkflowJob
        """
        if self.debug:
            print(f"- Getting jobs for workflow {workflow_id}")
        return self.get_items("workflow/%s/job" % workflow_id)

    def can_start(self, project_slug, branch, current_workflow_id):
        """
        Check if the workflow can start by checking if there are
        any other workflows for this project/branch running
        """
        pipelines = [item for item in self.pipelines(project_slug) if "branch" in item["vcs"] and item["vcs"]["branch"] == branch]
        for pipeline in pipelines:
            workflows = [item for item in self.workflows(pipeline["id"]) if item["id"] != current_workflow_id]
            for workflow in workflows:
                workflow_running_jobs = [item for item in self.jobs(workflow["id"]) if item["status"] == "running"]
                if len(workflow_running_jobs) > 0:
                    print(f'Found running jobs in workflow [{workflow["name"]}]')
                    return False
        print("No running jobs detected.")
        return True

parser = ArgumentParser( description='Checks if a CircleCI job is running for a given branch and waits for it to finish.', add_help=True)
parser.add_argument('-d', '--debug', required=False, default=False, action='store_true', dest='debug', help='Debug mode. Prints responses and other debug information.')
parser.add_argument('-b', '--branch', required=True, action='store', dest='target_branch_name', help='Target branch.')
parser.add_argument('-k', '--api-key', required=True, action='store', dest='api_token', help='API token key.')
parser.add_argument('-p', '--project-slug', required=True, action='store', dest='slug', help='Project slug (example: gh/codacy/codacy-coverage-reporter).')
parser.add_argument('-s', '--sleep', required=False, default=30, action='store', dest='sleep', type=int, help='Sleep time in seconds.')
parser.add_argument('-t', '--timeout', required=False, default=2400, action='store', dest='timeout', type=int, help='Timeout in seconds.')
parser.add_argument('-w', '--current-workflow', required=True, action='store', dest='current_workflow_id', help='Current workflow id.')
args = parser.parse_args()
if args.debug:
    print("cli arguments:", args)

circleci = CircleCIApi(args.api_token, args.debug)

timeout_count = 0
while timeout_count < args.timeout:
    if circleci.can_start(args.slug, args.target_branch_name, args.current_workflow_id):
        print("Workflow can now start.")
        sys.exit(0)
    timeout_count += args.sleep
    print(f"Sleeping for {args.sleep} seconds.")
    time.sleep(args.sleep)

print(f"Script timed out after {args.timeout} seconds. Exiting with failure...")
sys.exit(1)
