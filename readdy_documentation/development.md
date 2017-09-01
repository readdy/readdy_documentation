---
layout: page
title: Development
---

This section shall be a DevGuide, i.e. there will be implementation-related information which 
is not required for _using_ ReaDDy, but for understanding _how it works_.


{% assign sorted_development = site.development | sort: 'position' %}
{% for entry in sorted_development %}
<section id="{{ entry.sectionName }}">
<h1>{{ entry.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ entry.content | markdownify }}
</section>
{% endfor %}