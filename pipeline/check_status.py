#!/usr/bin/env python3
"""
CI/CD Platform Population Script
Generates comprehensive documentation and configuration files for all 20 CI/CD platforms
"""

import os
import json
from pathlib import Path

# Define platform configurations
PLATFORMS = {
    "gitlab-ci": {
        "name": "GitLab CI/CD",
        "type": "cloud_native",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "azure-pipelines": {
        "name": "Azure Pipelines",
        "type": "cloud_native",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "aws-codepipeline": {
        "name": "AWS CodePipeline",
        "type": "cloud_native",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "gcp-cloud-build": {
        "name": "GCP Cloud Build",
        "type": "cloud_native",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "circleci": {
        "name": "CircleCI",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "travis-ci": {
        "name": "Travis CI",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "appveyor": {
        "name": "AppVeyor",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "bitbucket-pipelines": {
        "name": "Bitbucket Pipelines",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "buildkite": {
        "name": "Buildkite",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "drone-ci": {
        "name": "Drone CI",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "concourse-ci": {
        "name": "Concourse CI",
        "type": "saas",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "jenkins": {
        "name": "Jenkins",
        "type": "selfhosted",
        "format": "groovy",
        "config_extension": ""
    },
    "teamcity": {
        "name": "TeamCity",
        "type": "selfhosted",
        "format": "kotlin",
        "config_extension": ""
    },
    "cloudbees": {
        "name": "CloudBees CI",
        "type": "selfhosted",
        "format": "groovy",
        "config_extension": ""
    },
    "gocd": {
        "name": "GoCD",
        "type": "selfhosted",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "tekton": {
        "name": "Tekton",
        "type": "kubernetes",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "spinnaker": {
        "name": "Spinnaker",
        "type": "kubernetes",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "harness": {
        "name": "Harness",
        "type": "kubernetes",
        "format": "yaml",
        "config_extension": ".yml"
    },
    "pulumi-automation": {
        "name": "Pulumi Automation",
        "type": "infrastructure",
        "format": "python",
        "config_extension": ".py"
    }
}

def check_platform_structure(platform_key):
    """Check what files exist for a platform"""
    platform_dir = Path(f"/workspaces/AI-prompt/pipeline/{platform_key}")
    
    status = {
        "platform": platform_key,
        "directory_exists": platform_dir.exists(),
        "files": {}
    }
    
    expected_files = [
        "README.md",
        "templates/basic.yml",
        "templates/advanced.yml",
        "examples/java-spring-boot-example.md",
        "examples/python-fastapi-example.md",
        "examples/nodejs-express-example.md",
        "examples/go-example.md",
        "docs/getting-started.md",
        "docs/advanced-configuration.md",
        "scripts/setup.sh",
        "scripts/validate.sh"
    ]
    
    for file_path in expected_files:
        full_path = platform_dir / file_path
        if full_path.exists():
            size = full_path.stat().st_size
            status["files"][file_path] = "exists" if size > 0 else "empty"
        else:
            status["files"][file_path] = "missing"
    
    return status

def main():
    print("=" * 80)
    print("CI/CD Platform Content Status Report")
    print("=" * 80)
    
    all_statuses = []
    
    for platform_key in sorted(PLATFORMS.keys()):
        status = check_platform_structure(platform_key)
        all_statuses.append(status)
        
        platform_name = PLATFORMS[platform_key]["name"]
        print(f"\n{platform_name} ({platform_key})")
        print("-" * 80)
        
        exists_count = sum(1 for f in status["files"].values() if f == "exists")
        empty_count = sum(1 for f in status["files"].values() if f == "empty")
        missing_count = sum(1 for f in status["files"].values() if f == "missing")
        
        print(f"  Exists:  {exists_count} | Empty:  {empty_count} | Missing: {missing_count}")
        
        # Show missing files
        missing_files = [f for f, s in status["files"].items() if s == "missing"]
        if missing_files:
            print(f"  Missing files:")
            for f in missing_files[:5]:
                print(f"    - {f}")
            if len(missing_files) > 5:
                print(f"    ... and {len(missing_files) - 5} more")
    
    print("\n" + "=" * 80)
    print("Summary")
    print("=" * 80)
    
    total_files = len(PLATFORMS) * 11  # 11 expected files per platform
    existing_files = sum(len([f for f, s in status["files"].items() if s == "exists"]) 
                         for status in all_statuses)
    empty_files = sum(len([f for f, s in status["files"].items() if s == "empty"]) 
                      for status in all_statuses)
    missing_files = sum(len([f for f, s in status["files"].items() if s == "missing"]) 
                        for status in all_statuses)
    
    print(f"Total Expected Files:  {total_files}")
    print(f"Existing with Content: {existing_files}")
    print(f"Empty Files:           {empty_files}")
    print(f"Missing Files:         {missing_files}")
    
    # Completion percentage
    completion = (existing_files / total_files) * 100 if total_files > 0 else 0
    print(f"\nCompletion: {completion:.1f}%")
    
    return all_statuses

if __name__ == "__main__":
    main()
