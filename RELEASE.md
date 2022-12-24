# How to release


A release consists of a few steps:

 - build a release version
 - create a GitHub release in unclebob/fitnesse
 - Update the website
 - deploy artifacts to Bintray
 - update the website on http://fitnesse.org
 - Propagate the released version from Bintray to Maven central
 - An account on https://oss.sonatype.org. Ask them for permission to publish on the `org.fitnesse` repo.

The following access is required:

 - SSH access to fitnesse.org - Ask Uncle Bob, Arjan or Fried
 - Push rights on the repos unclebob/fitnesse and fitnesse/fitnessedotorg
 - Deploy rights to the Bintray org for fitnesse


# The procedure

Most of the deployment process has been automated by the script `build-release.sh`.
The main function of this script is to update the website (`fitnessedotorg`) with
the information from the *real* source repository (`fitnesse`).

Firstly, make sure the `ReleaseNotes` page in the `fitnesse` is up to date.

You'll need to set your Bintray credentials in environment variables:

	export BINTRAY_USER=fhoeben
	export BINTRAY_API_KEY=7635726357797986533


Only the first time, initialize the submodules:

	git submodule init

Now the release script can be executed:

	./build-release.sh

Follow the instructions. Do not forget to add a message when committing.

To create a GitHub release:
- go to https://github.com/unclebob/fitnesse/tags
- click on the tag for the new release
- click `Create release from tag`
- click `Generate release notes`
- click `Publish release`

To update the website, go to your local checkout of the `fitnessedotorg` repo.

Be sure the following is added to `.git/config` of your local copy of `fitnessedotorg`:

	[remote "prod"]
		url = ec2-user@fitnesse.org:fitnessedotorg.git
		fetch = +refs/heads/*:refs/remotes/prod/*

Then push your changes to the GitHub repo and to the website (`prod`):

	git push prod master


Now wait a bit and a new website should be launched. You can also update the
version of FitNesse running by editing the `ivy.xml` file in `fitnessedotorg`
repo.
