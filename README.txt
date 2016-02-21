WLA Automation Framework
========================

This is the Ruby+WebDriver automation framework for the Autobars

Tips
====

If using git, you can ignore the Rakefile by using:

    git update-index --assume-unchanged Cucumber/Rakefile

This will ensure that your local changes to the Rakefile are not prompted as edits.
However, if you want to make a change to the Rakefile (to commit), you must reset this flag

    git update-index --no-assume-unchanged Cucumber/Rakefile

Warning: Untested with stashing / checkouts etc.
