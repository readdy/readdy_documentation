---
layout: page
title: Validation
---

{% assign sorted_tutorials = site.tutorials | sort: 'position' %}
{% for tutorial in sorted_tutorials %}
{% if tutorial.category == 'validation' %}
- <a href="{{ site.url }}{{ site.baseurl }}{{ tutorial.url }}">{{ tutorial.title | markdownify | remove: '<p>' | remove: '</p>' }}</a>
{% endif %}
{% endfor %}
