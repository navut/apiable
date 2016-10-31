# Apiable #

## Status ##
[![Code Climate](https://codeclimate.com/github/navut/apiable/badges/gpa.svg)](https://codeclimate.com/github/navut/apiable)
[![Test Coverage](https://codeclimate.com/github/navut/apiable/badges/coverage.svg)](https://codeclimate.com/github/navut/apiable/coverage)

## Description ##
## Features ##
## Usage ##

### Basic Usage ###

```
class User
  include Apiable::Object

  #
  # Any attribute (from the ORM) or method
  # can be declared to be listed in this simplified
  # version.
  #
  outgoing :name
  outgoing :email
  outgoing :level
end
```

```
@user = User.last
@user.external
# { name: 'John Doe', email: 'spiced@spam.com', level: :senior }
```

## Contributing ##

## License ##
See [LICENSE](/LICENSE) file.
