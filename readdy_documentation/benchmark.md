---
layout: page
title: Benchmark
---

{% assign sorted_tutorials = site.benchmark | sort: 'position' %}
{% for tutorial in sorted_tutorials %}
- <a href="{{ site.url }}{{ site.baseurl }}{{ tutorial.url }}">{{ tutorial.title | markdownify | remove: '<p>' | remove: '</p>' }}</a>
{% endfor %}
