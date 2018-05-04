Travis CI in all the Huws
===

A little app which syncs the status of projects you are testing on travis-ci.org to your [Philips Hue][1] lights.

Runs happily on a Mac or Raspberry Pi.

Installation
---

```Shell
bundle install
```

Then setup which lights map to which projects on [Travis CI][2]:

```Shell
bundle exec ruby setup.rb
```

And finally sync the projects state and lights:

```Shell
bundle exec ruby ruby.rb
```

### To Do:


- [ ] support for travis-ci.com
- [ ] support for Travsi CI Enterprise
- [ ] flash the light when it changes from Passing to Failing
- [ ] clean up the scripts
- [ ] add some basic tests


-------
[1]: http://meethue.com
[2]: https://travis-ci.org
