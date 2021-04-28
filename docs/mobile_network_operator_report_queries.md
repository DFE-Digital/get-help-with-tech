# Mobile Network Operator (MNO) report queries

## Introduction

The business might ask the development team for statistics related to Mobile Network Operators (MNOs). 
For instance, https://trello.com/c/P8etQAxi requested data on `ExtraMobileDataRequest`s on each 
network by school.

## Process

The queries which arrive could well be something different each time, so this work needs good 
general ActiveRecord or SQL query skills and an understanding of the relationships between classes.

The Product Manager can prioritise the requests as they come in. 

Typically the business will eventually want a Google Spreadsheet (usually created from a CSV file).
Those requesting these queries will often want something human-readable (so `school.name`
rather than `school.id`). 

`make download` provides a secure way of copying data from the Rails console to your local machine.

There's a `participating` scope on `MobileNetwork` which refers to MNOs which signed up to an early pilot scheme.

An `ExtraMobileDataRequest`'s `school_id` can be `nil` if it wasn't ordered by a school, but some
other responsible body instead.