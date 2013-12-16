github-api-bash
===============

GitHub API v3 scripts

#github_org_email_hooks.sh

Use GitHub's API to loop through every repo in an organization and add an email service hook
Has multi-page support for repos, not orgs

Auth token is read in from a separate file to make sure it is not committed into GitHub.

#To use with Mac
Install jq to parse JSON response
=> brew install jq

If you need to install brew
=> ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go)"

#References

GitHub API
	http://developer.github.com/v3/

An introduction to curl using GitHub's API
	https://gist.github.com/caspyin/2288960
