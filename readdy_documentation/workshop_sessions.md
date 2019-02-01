---
layout: page
title: Practical sessions
---

Here we'll gather the material and tasks for the daily sessions. 

{% assign sorted_sessions = site.workshop_sessions | sort: 'position' %}
{% for entry in sorted_sessions %}
<section id="{{ entry.sectionName }}">
<h1>{{ entry.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ entry.content | markdownify }}
</section>
{% endfor %}
