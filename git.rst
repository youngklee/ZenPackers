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

  [bash]: git add -a abc.py def.py
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


Synchronizing Local Branches and References: Pruning
-----------------------------------------------------
Sometimes you'll have a lot of old remote branch references that have
been long deleted on the hub. You can synchronize them with fetch::

    git fetch -p


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


Revert a Master Branch to a Prior Commit
--------------------------------------------------

*git revert* will create a new commit that will undo what the prior commit(s)  
have done and put that into your history. It gives you a log of your undo.

Comparison of Git Branches
---------------------------------------------------

* Show only relevant commits between two git refs::

   git log --no-merges master..develop


Avoiding a lot of small commit messages
---------------------------------------------------------------------
You can make as many small changes as you like and still have a clean
single commit by using git's amend flag on your commit::

    git commit --amend
    (make your commit message)
    (write/quit)

Every time you make a new commit in this way, you get the benefit of small
incremental changes and a clean commit log. If you have already made a mess
of things you can try the next technique to **Squash** your commits.


Squashing multiple commits to a single commit in a feature:
---------------------------------------------------------------------

In order to do this safely, we recommend only doing this in a feature branch
  (based on develop) that is not being shared. 
  
* From your feature branch, do a rebase with the -i flag::

    git rebase -i develop

* When it shows you the multiple commits, change command in commits after the first
  "pick" to "squash". Thus something like this::

      pick 01d1124 Adding license
      pick 6340aaa Moving license into its own file
      pick ebfd367 Jekyll has become self-aware.
      pick 30e0ccb Changed the tagline in the binary, too.

  now becomes::

      pick 01d1124 Adding license
      squash 6340aaa Moving license into its own file
      squash ebfd367 Jekyll has become self-aware.
      squash 30e0ccb Changed the tagline in the binary, too.


* Now you write that out and it will ask you to fix-up the commit logs.
  Do this by changing to a unified commit message::

    # This is a combination of 4 commits.
    # The first commit's message is:
    Dr Jekyll's final revisions to persona.

    Add that license thing
    Moving license into its own file
    Jekyll has become self-aware.
    Changed the tagline in the binary, too.

* Once you write that out, you need to push it up with force flag to rewrite
  history::

    git push -f 

* If you have already pushed it up prior to this, or even created a Pull,
  your upstream commits and pulls will get replaced with the unified commit.
_______________________________________________________________________________

=============================================================================
Git-Flow 
=============================================================================

Git flow simplifies development flow cycle.
See http://danielkummer.github.io/git-flow-cheatsheet/

.. _gitflow_setup:

Setup Git-Flow in the Existing Repo
------------------------------------
First go into the repo base folder. Make sure you get a clean *git status*.
Then you initialize the git repo for *git flow* as follows:

::

   [bash]: git flow init

      Which branch should be used for bringing forth production releases?
         - develop
      Branch name for production releases: [] master

      Which branch should be used for integration of the "next release"?
         - develop
      Branch name for "next release" development: [develop] 

      How to name your supporting branch prefixes?
      Feature branches? [feature/] 
      Release branches? [release/] 
      Hotfix branches? [hotfix/] 
      Support branches? [support/] 
      Version tag prefix? [] 
      Hooks and filters directory?
      [/data/zp/ZenPacks.zenoss.DB2/.git/hooks]

Create New Features and Work Flow
----------------------------------
In features, you don't want to use version numbers because it can
cause chaos when multiple authors work the same project. Instead
give the version a name, and only after the resulting develop is 
reviewed, you give it a version. (Source Unknown: Rob B).

To start a new feature::

    [bash]: git flow feature start area51
    [bash]: git flow feature publish
      - (This creates the feature branch on Github, and allows "push")
    [bash]: git status
        On branch feature/area51
        nothing to commit (working directory clean)
        
        .... do some work ....
        .... do some more work ....
        .... you are finished ....
        .... now commit ....

    [bash]: git commit -am "Comment: This fixes bug ZEN-3234823"
    [bash]: git push (nothing happens)
      . Counting objects: 4, done.
      . Writing objects: 100% (4/4), 647 bytes | 0 bytes/s, done.
      . Total 4 (delta 3), reused 0 (delta 0)
      . To git@github.com:zenoss/DB2.git
           6f1c83e..faf56f5  feature/area51 -> feature/area51

      - (Later you ask for a Pull Request or continue modifications)
      - (Someone may merge your Pull req into develop)
      - (Now you are finished with this feature...)
      - (You can either delete this branch or git-flow finish it)

    [bash]: git flow feature finish area51
    [bash]: git status
     On branch develop
     nothing to commit (working directory clean)

Now you are back on develop. You still need to push your changes up::

  [bash]: git push
   Total 0 (delta 0), reused 0 (delta 0)
   To git@github.com:zenoss/ZenPackers.git
   1530600..2873dc4  develop -> develop


Feature Drop from Develop to Feature/area51
-----------------------------------------------

So you have a fix in develop that needs to be pulled into your feature/area51 branch.
You will merge **develop** into feature/area51

* From your feature branch feature/area51, make sure you commit and push::

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

Somone has added to develop during your area51 while you were sleeeping.
This is common in a mulit-user environment. You will
have to merge the two together. To solve this, you need to: 

* Sync local develop with origin: checkout develop, pull from origin to
  develop::
    
    git checkout develop && git pull origin

* Rebase your feature on develop. You may have conflicts here if you're
  unlucky::

    git flow feature rebase area51


* Check that nothing is broken::

    git flow feature finish area51

* If things are still broken, you may need to do some surgery

Merge Conflicts: Fixing a Rebase
---------------------------------

 If you do have conflicts with your merge you can take a simple approach
to fixing them:

* Rebase against develop::

   [zenoss@austin]: git rebase develop
      First, rewinding head to replay your work on top of it...
      Applying: Make Tenant rels concrete
      Using index info to reconstruct a base tree...
      M       ZenPacks/zenoss/DB2/__init__.py
      Falling back to patching base and 3-way merge...
      Auto-merging ZenPacks/zenoss/DB2/__init__.py
      Falling back to patching base and 3-way merge...                                                                                                                                       [588/1329]
      Auto-merging ZenPacks/zenoss/DB2/__init__.py
      CONFLICT (content): Merge conflict in ZenPacks/zenoss/DB2/__init__.py
      Failed to merge in the changes.
      Patch failed at 0001 Make Tenant rels concrete
      The copy of the patch that failed is found in:
         /data/zp/ZenPacks.zenoss.DB2/.git/rebase-apply/patch

      When you have resolved this problem, run "git rebase --continue".
      If you prefer to skip this patch, run "git rebase --skip" instead.
      To check out the original branch and stop rebasing, run "git rebase --abort".

* Edit the problem file and fix::
  
   [zenoss@austin]: vi __init__.py
      ( fix fix fix )
   
   [zenoss@austin]: git status

      rebase in progress; onto 34ae002
      You are currently rebasing branch 'feature/ZEN-17143_installWarnings' on '34ae002'.
      (fix conflicts and then run "git rebase --continue")
      (use "git rebase --skip" to skip this patch)
      (use "git rebase --abort" to check out the original branch)

      Unmerged paths:
      (use "git reset HEAD <file>..." to unstage)
      (use "git add <file>..." to mark resolution)

            both modified:   __init__.py


* Add the file (you probably have to add this file back into to flock)::
 
   [zenoss@austin]: git add __init__.py

* Continue::
  
   [zenoss@austin]: git rebase --continue

      Applying: Make Tenant rels concrete
      Applying: fix impact relations
      Using index info to reconstruct a base tree...
      M       ZenPacks/zenoss/DB2/Tenant.py
      M       ZenPacks/zenoss/DB2/__init__.py
      Falling back to patching base and 3-way merge...
      Auto-merging ZenPacks/zenoss/DB2/__init__.py
      CONFLICT (content): Merge conflict in ZenPacks/zenoss/DB2/__init__.py
      CONFLICT (modify/delete): ZenPacks/zenoss/DB2/Tenant.py deleted in fix impact relations and modified in HEAD. Version HEAD of ZenPacks/zenoss/DB2/Tenant.
      py left in tree.
      Failed to merge in the changes.
      Patch failed at 0002 fix impact relations
      The copy of the patch that failed is found in:
         /data/zp/ZenPacks.zenoss.DB2/.git/rebase-apply/patch

      When you have resolved this problem, run "git rebase --continue".
      If you prefer to skip this patch, run "git rebase --skip" instead.
      To check out the original branch and stop rebasing, run "git rebase --abort"

* Repeat: You may have to edit/re-edit a file, re-add, and continue as before::

   [zenoss@austin]: vi __init__,py
   [zenoss@austin]: git add __init__.py
   [zenoss@austin]: git rebase --continue
      ZenPacks/zenoss/DB2/Tenant.py: needs merge
      You must edit all merge conflicts and then
      mark them as resolved using git add

* Delete what is required. You deleted a file but it is confused by this::

   [zenoss@austin]: git rm Tenant.py 
      ZenPacks/zenoss/DB2/Tenant.py: needs merge
      rm 'ZenPacks/zenoss/DB2/Tenant.py'

   [zenoss@austin]: git rebase --continue
      Applying: fix impact relations

   [zenoss@austin]: git st
      On branch feature/ZEN-17143_installWarnings
      Your branch and 'origin/feature/ZEN-17143_installWarnings' have diverged,
      and have 14 and 2 different commits each, respectively.
      (use "git pull" to merge the remote branch into yours)
      nothing to commit, working directory clean

* At this point the merge is good, but it asks you to pull. Probably ignore.?
  You really want to push your changes::

   [zenoss@austin]: git push
      To git@github.com:zenoss/ZenPacks.zenoss.DB2.git
       ! [rejected]        feature/ZEN-17143_installWarnings ->
       feature/ZEN-17143_installWarnings (non-fast-forward)
       error: failed to push some refs to
       'git@github.com:zenoss/ZenPacks.zenoss.DB2.git'
       hint: Updates were rejected because the tip of your current branch is
       behind
       hint: its remote counterpart. Integrate the remote changes (e.g.
       hint: 'git pull ...') before pushing again.
       hint: See the 'Note about fast-forwards' in 'git push --help' for details.

   [zenoss@austin]: git push --force
      Counting objects: 12, done.
      Delta compression using up to 8 threads.
      Compressing objects: 100% (12/12), done.
      Writing objects: 100% (12/12), 1.22 KiB | 0 bytes/s, done.
      Total 12 (delta 6), reused 0 (delta 0)
      To git@github.com:zenoss/ZenPacks.zenoss.DB2.git
      + 2bfc0a6...f7ddee9 feature/ZEN-17143_installWarnings ->
         feature/ZEN-17143_installWarnings (forced update)

   [zenoss@austin]: git st
      On branch feature/ZEN-17143_installWarnings
      Your branch is up-to-date with 'origin/feature/ZEN-17143_installWarnings'.
      nothing to commit, working directory clean


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
Git Access For Zenossians
========================================================================


If you yourself need a change in user permissions, or are asking on someone
else’s behalf, here’s how we handle it going forward:

#. Send an e-mail to github-owners@zenoss.com with a summary of your
   request in the subject. Examples:

   a. Need to grant pull and push access to joe_user to xyz_repo
   #. Need to remove all access from former_employee
   #. Need to enable write access for joe_user to all Zenoss repos

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


