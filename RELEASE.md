# How to release


A release consists of a few steps:

 - build a release version
 - create a GitHub release in unclebob/fitnesse
 - Update the website
 - deploy artifacts to Maven Central

The following access is required:

 - Push rights on the repos unclebob/fitnesse and fitnesse/fitnessedotorg
- An account on https://oss.sonatype.org. Ask them for permission to publish on the `org.fitnesse` repo.


# The procedure

Most of the deployment process has been automated by the script `build-release.sh`.
The main function of this script is to update the website (`fitnessedotorg`) with
the information from the *real* source repository (`fitnesse`).

Firstly, make sure the `ReleaseNotes` page in the `fitnesse` is up to date.

You'll need to set your Sonatype credentials and signing config in your gradle settings (e.g. via `~/.gradle/gradle.properties`):
```
sonatypeUsername=xxx
sonatypePassword=***

signing.keyId=yyy
signing.password=***
signing.secretKeyRingFile=/Users/zzz/.gnupg/secring.gpg
```


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
