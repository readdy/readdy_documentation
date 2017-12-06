---
layout: homepage
title: ReaDDy
---

Welcome to the website of ReaDDy - a particle-based reaction-diffusion simulator, written in C++ with python bindings. 
ReaDDy is an open-source project, developed and maintained by Moritz Hoffmann, Christoph Fröhner and Frank Noé 
of the Computational Molecular Biology group at the Freie Universität Berlin. This project continues
the [java software](https://github.com/readdy/readdy_java) of the same name, by
[Johannes Schöneberg](https://sites.google.com/a/schoeneberglab.org/johannes-schoeneberg/)
and Frank Noé.

We are making final changes before a first proper release in the very near future.
[Contact us](mailto:readdyadmin@lists.fu-berlin.de) if you want to use ReaDDy now or in some future project.

{% assign home_sections = site.home| sort: 'position' %}
{% for section in home_sections %}
<section id="{{ section.sectionName }}">
<h1>{{ section.title | remove: '<p>' | remove: '</p>'}}</h1>
{{ section.content | markdownify }}
</section>
{% endfor %}

