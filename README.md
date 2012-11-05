# Serif

<iframe src="https://docs.google.com/file/d/0BxPQpxGSOOyKS1J4MmlnM3JIaXM/preview" width="780" height="480"></iframe>

Serif is a file-based blogging engine intended for simple sites. It compiles Markdown content to static files, and there is a web interface for editing and publishing, because managing everything with `ssh` and `git` can be a pain, compared to having a more universally accessible editing interface.

_It should be considered alpha._ I make no promises it won't all change underneath you. **It is all subject to change, and is in a rough state.**

# Intro

Serif is a lot like Jekyll with a few extra moving parts, although it didn't start that way. It went through two reworkings before being converted into something based on generated Markdown files. The aim for Serif is to provide two things:

1. Simplicity: the source and generated content are just files that can be served by any web server.
2. Ease of publishing, wherever you are: having everything based on files that you edit in a text editor is a nice idea, but what if you're on a machine that doesn't give you ssh access to your server? What if you need to edit creation timestamps? What about editing drafts without having to make commits and push to git repos?

With this in mind, you might think of Serif's aim as to merge Jekyll, [Second Crack](https://github.com/marcoarment/secondcrack) and ideas from [Svbtle](http://dcurt.is/codename-svbtle). There should be many ways of editing and publishing, such as using the web interface, `rsync`ing from a remote machine, or editing a draft file on the remote server and having everything happen for you. (This last feature doesn't quite exist as planned yet.)

## Planned features

Some things I'm hoping to implement one day:

1. Custom hooks to fire after particular events, such as minifying CSS after publish, or committing changes and pushing to a git repository.
2. Simple Markdown pages instead of plain HTML.
3. Automatically detecting file changes and regenerating the site.
4. Adding custom Liquid filters and tags.

# License and contributing

Serif is released under the MIT license. See LICENSE for details.

Any contributions will be assumed by default to be under the same terms.

# Basics

## Installing

Installation is via [RubyGems](https://rubygems.org/). If you don't have Ruby installed, I recommend using [RVM](https://rvm.io/).

```bash
$ gem install serif
```

## Generating the site

```bash
$ cd path/to/site/directory
$ serif generate
```

(You may get warnings about "undefined method `gsub' for nil:NilClass" after a warning about trying to get headers out of a file. You should be able to ignore those.)

## Starting the admin server

```bash
$ cd path/to/site/directory
$ ENV=production serif admin
```

Once this is run, visit <http://localhost:4567/admin> and log in with whatever is in `_config.yml` as auth credentials.

Drop the `ENV=production` part if you're running it locally.

## Serving up the site for development

This runs a very simple web server that is mainly designed to test what the site will look like and let you make changes to stuff like CSS files without having to regenerate everything. Changes to post content will not be detected (yet).

```bash
$ cd path/to/site/directory
$ serif dev
```

Once this is run, visit <http://localhost:8000>.

## Generate a skeleton application

You can generate a skeletal directory to get you going, using the `new` command.

```bash
$ cd path/to/site/directory
$ serif new
```

# Content and site structure

The structure of a Serif site is something like this:

```
.
├── _site
├── _layouts
│   └── default.html
├── _drafts
│   ├── some-draft
│   └── another-unfinished-post
├── _posts
│   ├── 2012-01-01-a-post-you-have-written
│   ├── 2012-02-28-another-post
│   └── 2012-03-30-and-a-third
├── _templates
│   └─── post.html
├── _trash
├── _config.yml
├── css
│   └── ...
├── js
│   └── ...
├── images
│   └── ...
├── 404.html
├── favicon.ico
├── feed.xml
└── index.html
```

## `_site`

This is where generated content gets saved. You should serve files out of here, be it with Nginx or Apache. You should assume everything in this directory will get erased at some point in future. Don't keep anything in it!

## `_layouts`

This is where layouts for the site go. At the moment, there is only one supported: `default.html`.

## `_drafts` and `_posts`

Drafts go in `_drafts`, posts go in `_posts`. Simple enough.

Posts must have filenames in the format of `YYYY-MM-DD-your-post`. Drafts do not have a date part, since they're drafts and not published.

All files in these directories are assumed to be written in Markdown, with simple HTTP-style headers. The Markdown renderer is [Redcarpet](https://github.com/vmg/redcarpet) (with fenced code blocks enabled), with Smarty for punctuation tweaks, and Pygments to allow syntax highlighting (although you'll need your own CSS).

Here's an example post:

```
Title: A title of a post
Created: 2012-01-01T14:30:00+00:00

Something something.

1. A list
2. Of some stuff
3. Goes here

End of the post
```

The headers are similar to Jekyll's YAML front matter, but here there are no formatting requirements beyond `Key: value` pairs. Header names are case-insensitive (so `title` is the same as `Title`), but values are not.

(The headers `created` and `updated` must be a string that Ruby's standard Time library can parse, but this will mostly be handled for you.)

## `_templates`

This directory currently only has a single file in it, `post.html`, which is used to produce HTML content from Markdown files in `_posts`.

## `_trash`

Deleted drafts go in here just in case you want them back.

## `_config.yml`

Used for configuration settings.

Here's a sample configuration:

```yaml
admin:
  username: username
  password: password
permalink: /blog/:year/:month/:title
```

If a permalink setting is not given in the configuration, the default is `/:title`. There are the following options available for permalinks:

Placeholder | Value
----------- |:-----
`:title`    | URL "slug", e.g., "your-post-title"
`:year`     | Year as given in the filename, e.g., "2012"
`:month`    | Month as given in the filename, e.g., "01"
`:day`      | Day as given in the filename, e.g., "28"

## Other files

Any other file in the directory's root will be copied over exactly as-is, with two caveats for any file ending in `.html` or `.xml`:

1. These files are assumed to contain [Liquid markup](http://liquidmarkup.org/) and will be processed as such.
2. Any header data will not be included in the processed output.

For example, this would work as an `about.html`:

```html
<h1>All about me</h1>
<p>Where do I begin? {{ 'Well...' }}</p>
```

And so would this:

```html
title: My about page

<h1>All about me</h1>
<p>Where do I begin? Well...</p>
```

In both cases, the output is, of course:

```html
<h1>All about me</h1>
<p>Where do I begin? Well...</p>
```

If you have a file like `feed.xml` that you wish to _not_ be contained within a layout, specify `layout: none` in the header for the file.

# Deploying

To serve the site, set any web server to use `/path/to/site/directory/_site` as its root. *NOTE:* URLs generated in the site do not contain `.html` "extensions" by default, so you will need a rewrite rule. Here's an example rewrite for nginx:

```
error_page 404 @not_found_page;

location / {
	index  index.html index.htm;

	try_files $uri.html $uri $uri/ @not_found_page;
}

location @not_found_page {
	rewrite .* /404.html last;
}
```

## Admin interface

The admin server can be started on the live server the same way it's started locally (with `ENV=production`). To access it from anywhere on the web, you will need to proxy/forward `/admin` HTTP requests to port 4567 to let the admin web server handle it. As an alternative, you could forward a local port with SSH --- you might use this if you didn't want to rely on just HTTP basic auth, which isn't very secure over non-HTTPS connections.

# Customising the admin interface

The admin interface is intended to be a minimal place to focus on writing content. You are free to customise the admin interface by creating a stylesheet at `$your_site_directory/css/admin/admin.css`. As an example, if your main site's stylesheet is `/css/style.css`, you can use an `@import` rule to inherit the look-and-feel of your main site editing content and looking at rendered previews.


```css
/* Import the main site's CSS to provide a similar look-and-feel for the admin interface */

@import url("/css/style.css");

/* more customisation below */
```