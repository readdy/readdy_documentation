---
layout: page
title: Practical sessions
---

Here we'll gather the material and tasks for the daily sessions. 
Solutions to the tasks are found [here](https://github.com/chrisfroe/readdy-workshop-2018-session-notebooks)

{% assign sorted_sessions = site.sessions_2018 | sort: 'position' %}
{% for entry in sorted_sessions %}
<section id="{{ entry.sectionName }}">
<h1>{{ entry.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ entry.content | markdownify }}
</section>
{% endfor %}