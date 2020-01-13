# Stripe Income Analyzer

This is a cli tool that allows you to grab all your transactions (optionally setting a start date and an end date). The code spits out your total income, your net income and the amount in fees that stripe has taken that you can write off on your taxes.

# Instructions

Rename `example.api.yml` and `example.settings.yml` to `api.yml` and `settings.yml`. Api settings file requires a secret api code and the settings yaml file has optional settings for you to set.

# Debug

Pass `-d` or `-dump` to create a random `debug.RANDOM.log` log file.