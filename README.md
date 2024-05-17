[![Netlify Status](https://api.netlify.com/api/v1/badges/75c7bf17-7a68-412a-8bb3-e747d528fd11/deploy-status)](https://app.netlify.com/sites/pru-portal/deploys)

<<<<<<< HEAD
# Website
=======
# website 
>>>>>>> 202404-release-f3

This is the source repository of the [PRU web site](https://ansperformance.eu).

This site is automatically built and deployed by Netlify:

* branches named like `<YYYY><MM>-release*` are development branches for upcoming release


# Development

The configuration is such that the site will be generated in
`../aiu-portal-generated`

You can build it via

```
rmarkdown::render_site(encoding = 'UTF-8')
```

You can preview it by serving the page with

```
blogdown::serve_site(.site_dir = "../pru-portal-generated")
```

and then browsing at http://localhost:4321

# WARNINGS

In order to regenerate `csv.Rmd` you need access to the `performance/download`

