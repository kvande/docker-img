
# How to get this running on a Windows pc

## Setup gitlab web

1] Start out with running the docker-compose-web file
    . but first alter the Windows specific path in it
        .. the content in that path is used so that the container can restart without loosing all gitlab specific setup
    . run the file like this: docker-compose -f "docker-compose-web.yml" up -d

1 errors]
    ERROR: for gitlab-web  Cannot start service gitlab-web: error while creating mount source path '/host_mnt/f/Temp/gitlab-web': mkdir /host_mnt/f: file exists
        . 'gitlab nonsense', the directory must be manually created. Create and rerun command.

2] When container has started
    . open in Chrome 127.0.0.1:5123 (port 5123 from docker-compose-web, where port 5123 is mapped to 80 in container)
        .. register user
        .. create a new project ('gitlab visbility level' could be public for local testing purpose)

3] Fix clone url
    . the clone url for project created in 2] will be wrong, it looks something like this: git clone http://gitlabweb/abcdef/my-project.git
        .. docker container exec -it 'the container id' bash
        .. cd into: /etc/gitlab
        .. nano gitlab.rb
        .. uncomment line # external_url 'GENERATED_EXTERNAL_URL', change to external_url 'http://127.0.0.1'
        .. while still in docker container, restart gitlab: gitlab-ctl reconfigure
        .. refresh in Chrome (note, the page might be laggy, and not properly updating, give it a few minutes, and use ctrl-F5)
            ... check clone url, should now have changed to 'git clone http://127.0.0.1/abcdef/my-project.git'

4] Clone the repo
    . remarks, port must be added git clone http://127.0.0.1:5123/abcdef/my-project.git
        .. gitlab does not know that docker has been used to map port 80 to 5123 for the outside world


## Setup gitlab runner

1] In gitlab web; Settings -> CI/CD
    . grab the token
    . the url can not be used, must get the url of the docker container where gitlab web is running
        . get the url from:  docker container inspect --format "{{.NetworkSettings.IPAddress}}" 'the container id for gitlab web'
        . or just; docker container inspect 'the container id for gitlab web', if above does not work
        . below will be using ip "172.18.0.2"


2] Change content docker-compose-runner to match folder in Windows
    . and name if creating more runners


3] Run docker compose: 'docker-compose -f "docker-compose-runner.yml" up -d'
    . neglect 'WARNING: Found orphan containers' message


4] Register runner  
    . run 'docker run --rm -t -i -v F:\Temp\gitlab\gitlab-runner-one:/etc/gitlab-runner gitlab/gitlab-runner register'
        .. note F:\Temp\gitlab\gitlab-runner-one, it matches the path in the compose file
    . use ip from 1] (http://172.18.0.2"), not the one from gitlab web (http://127.0.0.1)
    . use token from web
    
5] Fixing check out path for gitlab runner
    . if/when encountering this, when pushing to repo at runner fails:
        Created fresh repository.
        fatal: unable to access 'http://gitlab-ci-token:[MASKED]@127.0.0.1/abcdef/my-project.git/': Failed to connect to 127.0.0.1 port 80: Connection refused
    . ip is wrong, have to fix it 
        .. either fix it in F:\Temp\gitlab-runner-one, or log into container at '/etc/gitlab-runner'
            ... add clone url in runner section of file config.toml: clone_url = "http://172.17.0.2" (remarks: no port, since this is all inside docker)
            ... restart container
            ...full file:

            concurrent = 1
            check_interval = 0

            [session_server]
            session_timeout = 1800

            [[runners]]
            name = "dockerrunner"
            url = "http://172.17.0.2"
            clone_url = "http://172.17.0.2"
            token = "gfPNWGUUJFJVoH7PmbCC"
            executor = "shell"
            [runners.custom_build_dir]
            [runners.cache]
                [runners.cache.s3]
                [runners.cache.gcs]
