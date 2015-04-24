Apigee-Checkin
===========

####First time cloning:

If cloning this repo for the first time, if the submodules do not init correctly, run the following command *from* your local repository folder:

`git submodule add git@github.com:ApigeeIgnite/ignite-iOS-engine.git _ignite-iOS-engine`

####Updating your local copy of the engine:

To update the submodule to the latest commit, enter the submodule directory:

`cd <yourProjectRepoFolder>/_ignite-iOS-engine`

Then pull from master to update the submodule:

`git pull origin master`

####Committing changes made to the engine when working with submodules:

Run `git commit -a` and fill in the appropriate comments. If you hate **vi** and want to use **nano** instead, run `git config --global core.editor nano`

Then commit your changes with `git push`
