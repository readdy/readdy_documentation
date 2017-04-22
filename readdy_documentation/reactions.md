---
layout: page
title: Reactions
---

These are the reactions ...
- a
- b
- c

{% assign sorted_reactions = site.reactions | sort: 'position' %}
{% for reaction in sorted_reactions %}
<section id="{{ reaction.sectionName }}">
<div class="entry-heading"><h2>{{ reaction.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ reaction.content | markdownify }}
</section>
{% endfor %}