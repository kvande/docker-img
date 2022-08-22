
# How to get this running on a Windows pc

## Setup gitlab web

### 1] Start out with running the docker-compose-web file  
* but, first alter the Windows specific path in it if needed  
the content in that path is used so that the container can restart without loosing all gitlab specific setup  
* pull latest image: `docker image pull gitlab/gitlab-ce` 
* run the file like this: `docker-compose -f "docker-compose-web.yml" up -d  `


### 2] When container has started  
This normally takes like 2 minutes.  
* `docker container exec -it gitlab-gitlab-web-1 bash`
* Gitlab creates a file called initial_root_password, do not bother using that, it will *not* work, just a waste of time
* install nano: `apt update && apt install nano -y`
* then run `cd /etc/gitlab` 
* next `nano gitlab.rb`  
(search in nano is ctr-w)  
.. uncomment line # external_url 'GENERATED_EXTERNAL_URL', change to external_url 'http://127.0.0.1:5123' (5123 have to match the one set in docker-compose)  
.. fix Git lfs (pretty far down). [NOPE! Better keep it disabled. Otherwise all kinds of problems]  Uncomment gitlab_rails['lfs_enabled']  
.. Also enable gitlab pages. Uncomment line # pages_external_url 'http://pages.example.com' (it is very far down), Change to url to http://127.0.0.1:5123,  (https://www.youtube.com/watch?v=dD8c7WNcc6s)  
.. save and close that file

* enable test report
.. run `gitlab-rails console -e production` (do not have to cd into any specific folder), this command takes like 30 seconds to execute  
.. in rails console, run: `Feature.enable(:junit_pipeline_view)`  (should repond with => true)  
.. then and run `exit` to end rails consol
* while still in docker container, restart gitlab: `gitlab-ctl reconfigure`


### 3 From version 14, GitLab do not present a change root user dialog at startup 
See this [link](https://forum.gitlab.com/t/how-to-login-for-the-first-time-local-install-with-docker-image/55297) about it.  
Use method from here: https://docs.gitlab.com/ee/security/reset_user_password.html#use-a-rails-console
* `docker container exec -it gitlab-gitlab-web-1 bash`  
* run `gitlab-rails console -e production` (do not have to cd into any specific folder), this command takes like 30 seconds to execute  
* run the command: `user = User.find_by_username 'root'`  (root is the default admin user)
* then these two commands: `user.password = 'my-secret-password'` and then confirm with `user.password_confirmation = 'my-secret-password'`
* save the changes `user.save!`             
* now it should be possible to logon web ui as admin with root@my-secret-password


### 4] Create new user
* open in Chrome 127.0.0.1:5123 (port 5123 from docker-compose-web, where port 5123 is mapped to 5123 in container, from 2] above)  
* register user
* log in with root user, and confirm that new user   


    

## Setup gitlab runner with shared Docker runners
If getting a 500 error on the admin page for shared runners 
* Try log out and back in. If that does not work follow this [link](https://docs.gitlab.com/ee/raketasks/backup_restore.html#reset-runner-registration-tokens).
* run `gitlab-rails dbconsole --database main` (takes likez)
* then all these commmands one by one:
    * `UPDATE projects SET runners_token = null, runners_token_encrypted = null;`
    * `UPDATE namespaces SET runners_token = null, runners_token_encrypted = null;` 
    * `UPDATE application_settings SET runners_registration_token_encrypted = null;` 
    * `UPDATE application_settings SET encrypted_ci_jwt_signing_key = null;` 
    * `UPDATE ci_runners SET token = null, token_encrypted = null;` 

### 1] Head over to http://localhost:5123/admin/runners
* grab the token
* the url can not be used, must get the url of the docker container where gitlab web is running
    * get the url from: `docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' gitlab-gitlab-web-1`
    * below will be using ip "172.18.0.2"


### 2] Change content docker-compose-runner to match ram disk folder in Windows


### 3] Create runner(s): 
* pull the latest image `docker pull gitlab/gitlab-runner`  
* change the name in the compose file, like .....-runner-one
* then run `docker-compose -f "docker-compose-runner-dotnet6-pwsh.yml" up -d`
* use dotnetcore, or dotnetcore with powershell core if such containers are needed
* neglect 'WARNING: Found orphan containers' message



### 4] Register runner  
* Example for runner one, have to change the path for runner-two etc
* run `docker run --rm -t -i -v D:\gitlab_ci\gitlab-runner-one:/etc/gitlab-runner gitlab/gitlab-runner register`
    .. note D:\gitlab_ci\gitlab-runner-one, it matches the path in the compose file
* use ip from 1] (http://172.18.0.2:5123"), not the one from gitlab web (http://127.0.0.1)
! port most be included !
* use token from web

### 5] Remove git lfs (if needed, might be needed in docker and windows host)   
* exec into git-lab runner `docker container exec -it gitlab-gitlab-runner-one-1 bash` 
* then run `which git-lfs` to confirm location
* delete that folder `rm -rf /usr/bin/git-lfs`
* it should now work
* there exists no uninstaller, see  (https://github.com/git-lfs/git-lfs/issues/316)


### 6] Fixing check out path for gitlab runner
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


### 7] Fix build dirs 
            [[runners]]
            name = "docker-runner-two"
            url = "http://172.17.0.2:5123"
            clone_url = "http://172.17.0.2:5123"
            builds_dir = "/home/gitlab/build_dir"       # match the one in the docker compose file, to utlize ram disk at R: in Windows
            token = "fgxZA4egaGhn-8ssRsiV"
            executor = "shell"
            [runners.custom_build_dir]
            [runners.cache]
                [runners.cache.s3]
                [runners.cache.gcs]
   

## Setup gitlab runner with shared Windows runners

### 1 Download latest version
Download the latest version [from here](https://docs.gitlab.com/runner/install/windows.html).
Rename the file in the Downloads folder to 'gitlab-runner.exe'.
Create as many folder as number of runners with the naming structure 'windows-runner-one' or 'windows-runner-one-docker-executor'

### 2 Install as a service
* Open a command prompt as admin
* Install the runner `gitlab-runner.exe install -n Gitlab-runner-one` (Gitlab-runner-one-docker for Docker executor)
* Start the runner `gitlab-runner.exe start -n Gitlab-runner-one`

### 3 Register the runner
For everyone of the Windows runners, run `gitlab-runner.exe register`
* use this url: http://127.0.0.1:5123/
* token from Gitlab
* name as Windows-runner-one or Windows-runner-one-docker
* executor either 'shell' or 'docker'

### 4 Update config.toml for Windows runners
* Change build dirs to this structure:  
`builds_dir = "S:/Gitlab-runners-working-dir/windows-runner-one"` 



##  Upgrade to newer versions
### Web

Check current version in web ui; add /help to the end of the base url.

0] Create backup if needed 

1] Pull new version of image (to make sure this works out ok, even when using a pull below): "docker pull gitlab/gitlab-ce".  

2] Run these commands to bring it all up again: 
    docker-compose -f "docker-compose-web.yml" down 
    docker-compose -f "docker-compose-web.yml" build --no-cache --pull (will run fast since image was pulled in 1 above)
    docker-compose -f "docker-compose-web.yml" up -d                   (will take serveral minutes, check status with "docker container ls")          

3] Wait for the container to start. Then, have to update '/etc/gitlab' again, since this not in a Docker volume, so repeat the step "2] in Setup gitlab web" above (external_url must be updated to gain web access again)

4] In case of failures: docker container logs 'container id', to see any errors, like: 

4a] If errors like this one
    "
    It seems you are upgrading from major version 13 to major version 14.  
    It is required to upgrade to the latest 13.12.x version first before proceeding  
    ."

    Pull an older image first, like: "docker pull gitlab/gitlab-ce:13.12.5-ce.0"

    Delete old latest image: "docker image rm gitlab/gitlab-ce:latest"

    Then re-tag it to latest to avoid updating compose-file: "docker image tag gitlab/gitlab-ce:13.12.5-ce.0 gitlab/gitlab-ce:latest"

    Then run commands in 2] again to check if it starts now. If so start on step 1] again.

4b] If the runner page will not open again (this page: http://localhost:...../-/settings/ci_cd)

(next time: Try not to clear "project tokens" and "group token". That will delete the ci variables, which is a bit anyoing if not needed to)


Delete all tokens according to this: 

https://docs-gitlab-com.translate.goog/ee/raketasks/backup_restore.html?_x_tr_sl=es&_x_tr_tl=en&_x_tr_hl=en-US&_x_tr_pto=ajax,se,elem#reset-runner-registration-tokens

Then, "gitlab-ctl reconfigure".

Runners will be probably been lost, re-add them :(



### Runner
- not started yet 