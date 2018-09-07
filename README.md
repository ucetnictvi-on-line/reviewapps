# Review apps

Usages and examples of this project are placed on [Medium](https://medium.com/blog-uoldevs-cz/gitlab-review-apps-d30b4f955ccb) (in czech language only).

## Installation

* Install **docker**
* Install **docker-compose**
* Install and register **gitlab-runner** with *shell* executor configuration
* `docker network create reverseproxy`
* Enable and configure **traefik**
* Copy directory structure to *RA server* (all files are placed under */usr/local/*).
* Configure `/usr/local/etc/reviewapps.conf`

## Usage

### Initialize project

This step create directory structure for specific project.

```bash
reviewapps new-project my_project
# Add build instructions specific to given project to $ROOT/$PROJECT/bin/build.sh
```

### Create app from branch

```bash
# Call from gitlab-runner
reviewapps up my_project some_branch /home/gitlab-runner/sources-of-some-branch
```

### Destroy app

```bash
# Call from gitlab-runner
reviewapps down my_project some_branch
```

## Exit codes

* **0** - Success
* **1** - Missing or wrong parameters
* **2** - Missing dependencies
* **3** - Lack of resources
* **4** - Project is not initialized
* **5** - Others
