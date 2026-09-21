You can delete this file once you are finished setting up.


This template provides a bare bones terraform setup so that you can immediately start creating AWS resources in a way that is compatible with our standards, and will play nice with Atlantis.

Some useful tidbits of information:

1. All workspaces must go under `terraform/dev|prod`, however you may create further nesting within those directories in any manner you wish.
2. The environment tfvars files setup in the `dev` directory are an Atlantis standard. Atlantis will run default by default, but you can provide optional flags so that Atlantis plans/applys changes to your personal env.
