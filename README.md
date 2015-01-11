# Travis CI in all the Hues

A little app which syncs the status of projects you are testing on travis-ci.org to your (Philips Hue)[http://meethue.com] lights.

Runs happily on a Mac or Raspberry Pi.

To install:
`bundle install`

Then setup which lights map to which projects on (Travis CI)[https://travis-ci.org]:
`bundle exec ruby setup.rb`

And finally sync the projects state and lights:
`bundle exec ruby ruby.rb`

## Yet to add
- support for travis-ci.com
- support for Travsi CI Enterprise
- flash the light when it changes from Passing to Failing
- clean up the scripts
- add some basic tests
