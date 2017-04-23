---
layout: page
title: Development
---

You will find information relevant for developers here.

{% assign sorted_development = site.development | sort: 'position' %}
{% for entry in sorted_development %}
<section id="{{ entry.sectionName }}">
<div class="entry-heading"><h2>{{ entry.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ entry.content | markdownify }}
</section>
{% endfor %}