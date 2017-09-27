---
layout: page
title: Reactions
---

Reactions remove particles from, and add particles to the system. They typically have a microscopic/intrinsic rate $k$.
This rate has units of inverse time and can be understood as the probability per unit time of the reaction occuring. Given a small integration step $\tau$ we will evaluate the probability of a reaction event as $p\approx k \tau$

{% assign sorted_reactions = site.reactions | sort: 'position' %}
{% for reaction in sorted_reactions %}
<section id="{{ reaction.sectionName }}">
<h1>{{ reaction.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ reaction.content | markdownify }}
</section>
{% endfor %}


