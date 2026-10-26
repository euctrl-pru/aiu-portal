[![Netlify Status](https://api.netlify.com/api/v1/badges/75c7bf17-7a68-412a-8bb3-e747d528fd11/deploy-status)](https://app.netlify.com/sites/pru-portal/deploys)

# ANS Performance Website

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

# Release
August 2024

# WARNINGS

In order to regenerate `csv.Rmd` you need access to the `performance/download`


# Automatic publication updates

A GitHub Action (`.github/workflows/update-publications.yml`) runs daily at 06:00 UTC (and on demand via "Run workflow", optionally as a dry run). It runs `scripts/pubsync`, which checks the EUROCONTROL website for new publications and adds them to `data/pub_*.yml` (images go to `static/images/auto/<key>/`). The site is built with Hugo as a gate; if the build succeeds the changes are committed and pushed to `master` by `pubsync-bot`, which triggers the Netlify deploy. If one series fails, the others are still published and the run is marked failed. A series whose data file has been hand-edited into a layout the YAML writer would change is skipped and reported rather than rewritten; restore the usual layout to resume it.

Automated series: `pub_eao`, `pub_coda_flad`, `pub_coda_digest`, `pub_coda_taxi`, `pub_datasnap`, `pub_flash`, `pub_think`, `pub_trends`, `pub_ace`, `pub_prr`, `pub_pi`, `pub_observer`.

Not automated (add by hand): `pub_statfor_forecast7`, `pub_statfor_update`, `pub_statfor_outlook`, `pub_statfor_2year`, `pub_analysis`. New STATFOR items are listed in the run summary so they can be filed manually.

Run locally (from the repository root, Python 3.12):

```
pip install -r scripts/pubsync/requirements.txt
python -m scripts.pubsync --dry-run
```

Without `--dry-run` it modifies `data/` and `static/images/auto/`. Tests: `pytest scripts/pubsync -q`.

Because the bot pushes to `master`, rebase release branches on `master` before editing `data/pub_*.yml` by hand to avoid conflicts.
