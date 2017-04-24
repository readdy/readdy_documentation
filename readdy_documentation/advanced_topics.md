---
layout: page
title: Advanced Topics
---

{% assign sorted_topics = site.advanced_topics | sort: 'position' %}
{% for topic in sorted_topics %}
<section id="{{ topic.sectionName }}">
<div class="entry-heading"><h2>{{ topic.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ topic.content | markdownify }}
</section>
{% endfor %}