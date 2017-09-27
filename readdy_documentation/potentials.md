---
layout: page
title: Potentials
---

Potentials create an energy landscape in which particles diffuse in, subject to the corresponding forces.
They can be used to build traps, obstacles or compartments for particles.
Or for clustering and crowding effects that are typically observed in biological fluid-like media.

Potentials in ReaDDy are divided into first-order potentials/__external potentials__,
i.e. those that depend only on the position of one particle, and
second-order potentials/__pair potentials__, i.e. those that depend on the relative 
position of two particles. 
The [topology]({{site.baseurl}}/topologies.html) functionality also provides higher order potentials like angles and dihedrals.

<section id="firstorderpotentials">
<div class="entry-heading"><h1>External potentials</h1></div>
</section>

{% assign sorted_potentials_o1 = site.potentials_order1 | sort: 'position' %}
{% for potential in sorted_potentials_o1 %}
<section id="{{ potential.sectionName }}">
<h1>{{ potential.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ potential.content | markdownify }}
</section>
{% endfor %}

<section id="secondorderpotentials">
<div class="entry-heading"><h1>Pair potentials</h1></div>
</section>

{% assign sorted_potentials_o2 = site.potentials_order2 | sort: 'position' %}
{% for potential in sorted_potentials_o2 %}
<section id="{{ potential.sectionName }}">
<h1>{{ potential.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ potential.content | markdownify }}
</section>
{% endfor %}
