---
layout: page
title: Simulation
---

The `system` object generates a `simulation` object, which determines _how_ to simulate the `system`.
This includes the diffusion integrator, the reaction handler, [observables]({{site.baseurl}}/observables.html).
The initial positions of particles are also set on the `simulation` object.

{% assign sections = site.simulation | sort: 'position' %}
{% for section in sections %}
<section id="{{ section.sectionName }}">
<h1>{{ section.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ section.content | markdownify }}
</section>
{% endfor %}
