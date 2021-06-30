# HubSpot-ruby timeline events sample app

### Requirements

1. ruby 2.6.3
2. [Configured](https://github.com/HubSpot/sample-apps-timeline-events/blob/main/README.md#how-to-run-locally) .env file

### Running

1. Install dependencies

```
bundle install
```

2. Commands

Show all commands (get help)

```
ruby cli.rb -h
```

Create timeline event with existing contact and template

```
ruby cli.rb -c [contact_id] -e [email] -t [template_id]
```

Create timeline event with new contact and template

```
ruby cli.rb -f [first_name] -l [last_name] -e [email] -o [object_type] -n [template_name] -h [template_header] -d [template_detail]
```
