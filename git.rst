========================================================================
Git for Gits ;)
========================================================================

Git is a developement version control tool. 

Beginning
------------------------------------------------------------------------
To just pull (download) a repository from the web:

* Find the repo online and get the clone string.
* Copy that string.
* pull it down with "git clone"

::
  
  [bash]: git clone git@github.com:zenoss/ZenPackers.git

    - or for https - 

  [bash]: git clone https://github.com/zenoss/ZenPackers.git

Cool Ways to Show Logs and Diffs
----------------------------------

Often you will need to see your logs and compare different versions::

   git log
   git log --oneline --graph --decorate --all
   git diff
   git diff fe492a1 #(between current and some other node)
   git diff be158f6 aee7163 #(between two nodes)

Typical Workflow Scenario
--------------------------------------------------------------

Now that you have a repo, go into the repo folder.

* Add any files you want
* Make any changes you want to files
* Commit your changes
* Push your changes

To add your new files::

  [bash]: git add -a xyz.py abc.py
  [bash]: git add -A (Danger: adds and removes files from working tree)

To commit all changes execute::

  [bash]: git commit -a

To finally push up your changes to your Repo hub (or github.com)::

  [bash]: git push

New Repo Workflow Scenario
--------------------------------------------------------------

* First go to github.com and create your account
* Then create an empty repository in the GUI
* Now on your workstation, pull down (clone) the empty repo::

  [bash]: git clone https://github.com/zenoss/bogus.git
  [bash]: cd bogus/

* Now start writing your code, make files......
* Now add files to your repo and push::

   [bash]: git add -A
   [bash]: git commit -a
   [bash]: git push
   [bash]: git status
   .. Already up-to-date ..

Setting Repo Parameters
----------------------------------------------

* Configure the Username and Email for the Repo::

  [bash]: git config --global user.name "Joe Frazer"
  [bash]: git config --global user.email joe@zenoss.com

* Reset the Author for the Repo::

  [bash]: git commit --amend --reset-author

Changing Branches
-------------------------

* Change branch from **master** to **develop** with *checkout*::

  [bash]: git checkout develop
  [bash]: git status

Merging Branches
-------------------------

You like the work you've done in develop and think it should be merged into master.
You can do this by using the *merge* option.

* First change branches from develop to master::

  [bash]: git checkout master

Now things are as before with master in its original state. 

* Now you want to merge from develop::

   [bash]: git merge develop
     Updating 1530600..2873dc4
     Fast-forward
     .gitignore                             |    2 +
     Makefile                               |   11 +-
     ....

* Now you must push these changes up to your Hub::

   [bash]: git push
     Total 0 (delta 0), reused 0 (delta 0)
     To git@github.com:zenoss/ZenPackers.git
     1530600..2873dc4  master -> master


Delete Unwanted Branches
------------------------
If you want to eject unwanted branches from your repo,
make sure to read the git-branch docs and the warnings about being
fully merged (--delete option).

To remove a local branch::

  git branch -D <branchName>

To remove a  remote branch::
  
  git push origin --delete <branchName>


Resetting a Master Branch to a Prior Commit
--------------------------------------------------
* git checkout master
* Identify the number of your last "good" commit::

    git log
    (grab the good commit number: e3f1e37)

* Reset your master to that commit level::
  
    git reset --hard e3f1e37

* Push it up to github::

    git push --force origin master

* Test the diff between local and remote: Should show nothing::

    git diff master..origin/master


Comparison of Git Branches
---------------------------------------------------

* Show only relevant commits between two git refs::

   git log --no-merges master..develop

_______________________________________________________________________________

=============================================================================
Git-Flow 
=============================================================================

Git flow simplifies development revisioning.
http://danielkummer.github.io/git-flow-cheatsheet/

Setup Git-Flow in the Existing Repo
------------------------------------
::

   [bash]: git flow init

Create New Features and Work Flow
----------------------------------
In features, you don't want to use version numbers because it can
cause chaos when multiple authors work the same project. Instead
give the version a name, and only after the resulting develop is 
reviewed, you give it a version. (Source Unknown: Rob B).

To start a new feature::

    [bash]: git flow feature start xyz
    [bash]: git flow feature publish xyz
      - (This creates the feature branch on Github, and allows you to "push")
    [bash]: git status
        On branch feature/xyz (don't give version #'s)
        nothing to commit (working directory clean)
        
        .... do some work ....
        .... do some more work ....
        .... you are finished ....

    [bash]: git commit -am "Comment: this new feature fixes bugs"
    [bash]: git push (nothing happens)
      - (At this point you can ask for a Pull Request or continue)
      - (Now you are finished with this feature...)
    [bash]: git flow feature finish xyz
    [bash]: git status
     On branch develop
     nothing to commit (working directory clean)

Now you are back on develop. You still need to push your changes up::

  [bash]: git push
   Total 0 (delta 0), reused 0 (delta 0)
   To git@github.com:zenoss/ZenPackers.git
   1530600..2873dc4  develop -> develop


Feature Drop from Develop to Feature/XYZ
-----------------------------------------

So you have a fix in develop that needs to be pulled into your feature/xyz branch.
You will merge **develop** into feature/xyz

* From your feature branch feature/xyz, make sure you commit and push::

  [bash]: git commit -a 
  [bash]: git push

* Now merge from develop::

  [bash]: git merge develop
  [bash]: git push origin develop
 
* You may have to deal with merge conflicts as this point.


Push the Develop onto the old Feature that is Stale
----------------------------------------------------
You have created a branch (forgotten) that has been left behind and wish upgrade
it with all the new changes that have been made with other feature enhancements.
You don't have anything to save in it. Use these commands (with caution)
to merge develop back onto feature/forgotten::

  [bash]: git checkout feature/forgotten
  [bash]: git push . develop:feature/forgotten
  [bash]: get checkout feature/forgotten
  [bash]: git commit -a
  [bash]: git push

Push a new Feature up to Origin for storage:
-----------------------------------------------------
Sometimes you want a feature to be stored on your Hub.
Git-Flow does not automatically push your features.
You can push it up to the hub like this::

  [bash]: git push -u origin feature/new

Branches 'develop' and 'origin/develop' have diverged
------------------------------------------------------

You get these messages

.. WARNING::

    Branches 'develop' and 'origin/develop' have diverged.
    Fatal: And branch 'develop' may be fast-forwarded.

Somone has added to develop during your feature XYZ while you were sleeeping.
This is common in a mulit-user environment. You will
have to merge the two together. To solve this, you need to: 

* Sync local develop with origin: checkout develop, pull from origin to
  develop::
    
    git checkout develop && git pull origin

* Rebase your feature on develop. You may have conflicts here if you're
  unlucky::

    git flow feature rebase XYZ


* Check that nothing is broken::

    git flow feature finish XYZ

* If things are still broken, you may need to do some surgery

Git Stash: Stashing Modified Files
------------------------------------

Git's *stash* option allows you to put modified files into a temporary holding
area. The usual scenario is to stash your mods away then pull from the origin,
and then re-place your stash'ed files into the tree. Then you can push the 
results back up to origin. Here is a possible workflow::

  .... you made changes to develop, but you'd rather it be in a feature....

  [bash]: git stash
   > Saved working directory and index state WIP on develop: e38b798 post
   release: 1.0.1 -> 1.0.2dev.....

  [bash]: git flow feature start cleanup_on_aisle_7
   > Switched to a new branch 'feature/cleanup_on_aisle_7'

  [bash]: git stash pop
  .... now you have your new mods overlaid ....
  .... make whatever other modifications ....
  .... now you can commit all your mods ....

  [bash]: git commit -a

  [bash]: git flow feature finish cleanup_on_aisle_7

  [bash]: git push

Pull Requests: The Easy Way
----------------------------

The easiest way we have to get your code reviewed and merged into a major
branch is to use Git-Flow to create a feature, push that feature up to Github,
and have someone review it. 

Here is the workflow in a nutshell:

* Create your feature with **git flow**
* Make your mods
* Commit your mods
* Push (or publish) your feature up to Gitflow
* Go into the Github GUI, select your feature
* Make your pull request
* Ask for a review
* That reveiwer then **merges** your changes into develop
* Finsh your feature locally: 

  - Using git push.default=simple: Everything on Github is cleaned for you.
    (See the `Push Defaults`_ section)
  - Otherwise: After finishing, remove the feature repo in Github

* Finally, from your local repo, do a **"git pull"** to sync up

Push Defaults
----------------

To set your push defaults you can edit your .gitconfig and put this option::

   [user]        
                 name = Pat Mibak
                 email = patmibak@zenoss.com
   [push]       
                 default = simple

* Note: See git-config man page: Search /push.default for more details

Git 1.X and 2.X Warnings and Errors
--------------------------------------

* You may you get this warning when trying to push a new branch to origin::

   [bash]: git push
   fatal: The current branch develop has no upstream branch.
   To push the current branch and set the remote as upstream, use

       git push --set-upstream origin develop

  Its usually safe to follow this suggestion

_______________________________________________________________________________

========================================================================
HotFixes With Git-Flow
========================================================================

* Target develop to next minor release if it's not already so:

    #. git checkout develop
    #. git pull
    #. # edit setup.py: change VERSION 2.2.1dev -> 2.3.0dev
    #. git commit -a -m "Start 2.3.0 Release: Version 2.2.1dev -> 2.3.0dev"
    #. git push

* Start the hotfix for the next patch release if it's not already started:

    #. git checkout master
    #. git pull
    #. git flow hotfix start 2.2.1
    #. # edit setup.py: change VERSION 2.2.0 -> 2.2.1dev
    #. git commit -a -m "Start 2.2.1 Hotfix: Version 2.2.0 -> 2.2.1dev"
    #. git push

* Commit changes to hotfix:

    #. # make and commit chang(es) needed in 2.2.1 hotfix including README.mediawiki updates.
    #. git push

* Finish hotfix when all changes are committed:

    #. # edit setup.py: change VERSION 2.2.1dev -> 2.2.1
    #. git commit -a -m "Finish 2.2.1 Hotfix: Version 2.2.1dev -> 2.2.1"
    #. git flow hotfix finish
    #. git push --all
    #. git push --tags

* Now run a build of the master-ZenPacks.zenoss.X Jenkins job if it hasn't
  already run it, and verify that the artifact has the new (2.2.1) version
  with no dev suffix.

.. NOTE:: For a hotfix with a single patch that isn't going to remain open
          for additional patches you just run through all of these steps
          sequentially. We broke them out to make it clear that a hotfix branch can
          remain open for a while and the process is less synchronous in that case.

========================================================================
Git Access For Zenossians
========================================================================


If you yourself need a change in user permissions, or are asking on someone
else’s behalf, here’s how we’ll handle it going forward.

#. Send an e-mail to github-owners@zenoss.com with a summary of your
   request in the subject. Examples:

   a. Need to grant pull and push access to foo_user to xyz_repo
   #. Need to remove all access from former_employee
   #. Need to enable write access for foo_user to all Zenoss repos

#. The email body needs to include the following:

   a. The user's full name
   #. The user's email address
   #. The user's github name
   #. The user's department or role (why are they being added to the org in the first place?)
   #. The user's skype name
   #. The user's Docker Hub username, if available
   #. Whether the user is an employee, or a contractor

*Special note on the Owners group in Github*
---------------------------------------------

Owners have access to the billing information for the organization, and can
create and delete teams.  Owners can also delete any repo, which is one of
the main risks we want to contain by better managing GitHub permissions.


