# Roast [![Build Status](https://travis-ci.org/blahed/roast.png?branch=master)](https://travis-ci.org/blahed/roast)

Roast helps you manage entries in your `/etc/hosts` file. Roast allows you to group entries together in a named group and disable/enable them all at once. It's pretty useful if you work with a lot of entries in your hosts file and find it annoying to constantly be enabled/editing your hosts file manually.

## Installation

```bash
$ gem install roast
```

## Commands

Roast has a decent set of commands available:
```
list                list the entries in the hosts file          alias: l
add                 adds a new entry to the hosts file          alias: a
enable              enables a disabled (commented out) entry    alias: e
enable-group        enables an entire group                     alias: eg
disable             disables an entry (comments it out)         alias: d
disable-group       disables an entire group                    alias: dg
delete              deletes an entry entirely
delete-group        deletes an enitre group
```
*a few of the commands have aliases, they are listed to the right*

## Usage

A few examples of using roast to manage your `/etc/hosts` file:
```bash
# list all entires
$ roast list

# add an entry to the base group
$ sudo roast add 10.0.1.1 something.dev

# add an entry to the "testing" group
$ sudo roast add testing 127.0.0.1 exampleapp.dev

# disable all entries with the ip "10.0.1.1"
$ sudo roast disable 10.0.1.1

# delete an entry entirely
$ sudo roast delete exampleapp.dev
```

*notice that you can list entries without sudo, but editing the hosts file does require sudo*

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
