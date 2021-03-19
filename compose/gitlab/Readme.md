
# How to get this running on a Windows pc

## Setup gitlab web

1] Start out with running the docker-compose-web file
   > but first alter the Windows specific path in it
        > - the content in that path is used so that the container can restart without loosing all gitlab specific setup
    > - . run the file like this: docker-compose -f "docker-compose-web.yml" up -d

1 errors]
    > - ERROR: for gitlab-web  Cannot start service gitlab-web: error while creating mount source path '/host_mnt/f/Temp/gitlab-web': mkdir /host_mnt/f: file exists
        . 'gitlab nonsense', the directory must be manually created. Create and rerun command.

2] When container has started
    * docker container exec -it 'the container id' bash
    * cd into: /etc/gitlab
    * in gitlab.rb uncomment line # external_url 'GENERATED_EXTERNAL_URL', change to external_url 'http://127.0.0.1:5123'   (5123 have to     match the one set in docker-compose)
    .. fix Git lfs (pretty far down). Uncomment gitlab_rails['lfs_enabled']
    .. Also enable gitlab pages. Uncomment line # pages_external_url 'http://pages.example.com' (it is very far down), Change to url to http://127.0.0.1:5123,  (https://www.youtube.com/watch?v=dD8c7WNcc6s)
    .. while still in docker container, restart gitlab: gitlab-ctl reconfigure

3] Create a project
    . open in Chrome 127.0.0.1:5123 (port 5123 from docker-compose-web, where port 5123 is mapped to 5123 in container, from 2] above)
        .. register user
        .. create a new project ('gitlab visbility level' could be public for local testing purpose)

4] Clone the repo

5] Optional, enable test report
    .. exec into container
    .. run: gitlab-rails console -e production (do not have to cd into any specific folder)
    .. in rails console, run: Feature.enable(:junit_pipeline_view)
    

## Setup gitlab runner

1] In gitlab web; Settings -> CI/CD
    . grab the token
    . the url can not be used, must get the url of the docker container where gitlab web is running
        . get the url from:  docker container inspect --format "{{.NetworkSettings.IPAddress}}" 'the container id for gitlab web'
        . or just; docker container inspect 'the container id for gitlab web', if above does not work
        . below will be using ip "172.18.0.2"


2] Change content docker-compose-runner to match folder in Windows
    . and name if creating more runners


3] Run docker compose: docker-compose -f "docker-compose-runner-dotnet5-pwsh.yml" up -d
    . use dotnetcore, or dotnetcore with powershell core if such containers are needed
    . neglect 'WARNING: Found orphan containers' message


4] Register runner  
    . run 'docker run --rm -t -i -v D:\gitlab_ci\gitlab-runner-one:/etc/gitlab-runner gitlab/gitlab-runner register'
        .. note D:\gitlab_ci\gitlab-runner-one, it matches the path in the compose file
    . use ip from 1] (http://172.18.0.2:5123"), not the one from gitlab web (http://127.0.0.1)
    ! port most be included !
    . use token from web

5] Remove git lfs (if needed, might be needed in docker and windows host)   
    . exec into git-lab runner
    . then run: which git-lfs
    . delete that folder (rm -rf /usr/bin/git-lfs)
    . it should now work
    . there exists no uninstaller, see  (https://github.com/git-lfs/git-lfs/issues/316)


6] Fixing check out path for gitlab runner
    . if/when encountering this, when pushing to repo at runner fails:
        Created fresh repository.
        fatal: unable to access 'http://gitlab-ci-token:[MASKED]@127.0.0.1/abcdef/my-project.git/': Failed to connect to 127.0.0.1 port 80: Connection refused
    . ip is wrong, have to fix it 
        .. either fix it in F:\Temp\gitlab-runner-one, or log into container at '/etc/gitlab-runner'
            ... add clone url in runner section of file config.toml: clone_url = "http://172.17.0.2:5123"
            ... restart container
            ...full file:

            concurrent = 1
            check_interval = 0

            [session_server]
            session_timeout = 1800

            [[runners]]
            name = "docker-runner-two"
            url = "http://172.17.0.2:5123"
            clone_url = "http://172.17.0.2:5123"
            token = "fgxZA4egaGhn-8ssRsiV"
            executor = "shell"
            [runners.custom_build_dir]
            [runners.cache]
                [runners.cache.s3]
                [runners.cache.gcs]

