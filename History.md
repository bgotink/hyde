## v0.2.1 / 2014-01-11

### Minor Enhancements
  * change in template now also triggers jekyll rebuild
  * a post called index.ext is now not added to the _posts but as index for the category
  * only parse front-matter if needed (aka: if file is a post), this allows the user to enter a directory filled with images etc. as a page

### Bugfixes
  * index.ext can now also be updated using --watch

## 0.2.0 / 2014-01-08

### Major Enhancements
  * moved from `map` to `pages` and `posts` in `_config.yml`
  * allow files to be included in `pages` and `posts` directly instead of requiring directories
  * automatically checkout jekyll template from different branch while building
  * also allow destination to be a git branch
  
### Bugfixes
  * fixed rake release

## 0.1.0 / 2014-01-08

### Major Enhancements
  * copied and modified gemspec, rakefile etc. from [jekyll](//github.com/jekyll/jekyll)
  * wrote `bin/hyde` based on `jekyll` script
  * created build command
  * created serve command
  * use `mtime` to obtain a date to give jekyll
  * allow usage of `hyde_data: `, which takes precedense over `mtime`

## 0.0.0 / 2014-01-07
  * Birthday! (no really, 23rd birthday)
