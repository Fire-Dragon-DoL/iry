# Iry

Convert constraint errors into Rails model validation errors.

## Usage

Given the following database schema:

```sql
create extension if not exists "pgcrypto";
create extension if not exists "btree_gist";

create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    unique_text text unique not null default gen_random_uuid()::text
    created_at timestamp(6) not null,
    updated_at timestamp(6) not null
);
```

The following constraint can be used on the `User` class:

```ruby
class User < ActiveRecord::Base
  include Iry

  belongs_to :user, optional: true

  unique_constraint :unique_text
end
```

When saving a new `User` record or updating it, in case constraint exceptions are raised, these will be rescued and
validation errors will be applied to the record, like in the following example:

```ruby
user = User.create!(unique_text: "some unique text")

fail_user = User.create(unique_text: "some unique text")

fail_user.errors.details.fetch(:unique_text) #=> [{error: :taken}]
```

Multiple constraints of the same or different types can be present on the model, as long as the `:name` is different.

The following constraint types are available:
- [`check_constraint`](#check_constraint)
- [`exclusion_constraint`](#exclusion_constraint)
- [`foreign_key_constraint`](#foreign_key_constraint)
- [`unique_constraint`](#unique_constraint)

The class method `.constraints` is also available, that returns all the constraints applied to a model.

## Constraints

### `check_constraint`

Catches a specific check constraint violation.

- **key** (`Symbol`) which key will have validation errors added to
- **name** (optional `String`) constraint name in the database, to detect constraint errors. Infferred if omitted
- **message** (optional `String` or `Symbol`) error message, defaults to `:invalid`

### `exclusion_constraint`

Catches a specific exclusion constraint violation.

- **key** (`Symbol`) which key will have validation errors added to
- **name** (optional `String`) constraint name in the database, to detect constraint errors. Infferred if omitted
- **message** (optional `String` or `Symbol`) error message, defaults to `:taken`

### `foreign_key_constraint`

Catches a specific foreign key constraint violation.

- **key_or_keys** (`Symbol` or array of `Symbol`) key or keys used to make the foreign key constraint
- **name** (optional `String`) constraint name in the database, to detect constraint errors. Infferred if omitted
- **message** (optional `String` or `Symbol`) error message, defaults to `:required`
- **error_key** (optional `Symbol`) which key will have validation errors added to

### `unique_constraint`

Catches a specific foreign key constraint violation.

- **key_or_keys** (`Symbol` or array of `Symbol`) key or keys used to make the unique constraint
- **name** (optional `String`) constraint name in the database, to detect constraint errors. Infferred if omitted
- **message** (optional `String` or `Symbol`) error message, defaults to `:taken`
- **error_key** (optional `Symbol`) which key will have validation errors added to

## Limitations

- `valid?` will not check for constraints. If calling `valid?` right after a `save` operation, keep in mind `errors`
    are cleared
- `create!` and `update!` will raise `ActiveRecord::RecordNotSaved` for constraints that are caught by `iry`, instead
    of `ActiveModel::ValidationError`
- Currently only PostgreSQL is supported with the `pg` gem, but it should be simple to add support for other databases.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add iry

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install iry

## Development

**Requirements:**
- PostgreSQL with `psql`, `createdb`, `dropdb`
- NodeJS 18 with `npm`

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fire-Dragon-DoL/iry.
