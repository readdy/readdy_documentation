---
layout: page
title: Potentials
---

These are the potentials ...

<section id="firstorderpotentials">
<h1>First order potentials</h1>
</section>

{% assign sorted_potentials_o1 = site.potentials_order1 | sort: 'position' %}
{% for potential in sorted_potentials_o1 %}
<section id="{{ potential.sectionName }}">
<div class="entry-heading"><h2>{{ potential.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ potential.content | markdownify }}
</section>
{% endfor %}

<section id="secondorderpotentials">
<h1>Second order potentials</h1>
</section>

{% assign sorted_potentials_o2 = site.potentials_order2 | sort: 'position' %}
{% for potential in sorted_potentials_o2 %}
<section id="{{ potential.sectionName }}">
<div class="entry-heading"><h2>{{ potential.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ potential.content | markdownify }}
</section>
{% endfor %}