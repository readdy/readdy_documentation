---
layout: page
title: Practical sessions
---

After each session you will find the solutions
to the notebooks [here](https://github.com/chrisfroe/readdy-workshop-2017-solutions).

{% assign sorted_sessions = site.workshop_sessions | sort: 'position' %}
{% for session in sorted_sessions %}
<section id="{{ session.sectionName }}">
<div class="entry-heading"><h2>{{ session.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ session.content | markdownify }}
</section>
{% endfor %}
