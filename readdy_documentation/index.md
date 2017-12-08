---
layout: homepage
title: ReaDDy
---

Welcome to the website of ReaDDy - a particle-based reaction-diffusion simulator, written in C++ with python bindings. 
ReaDDy is an open-source project, developed and maintained by [Moritz Hoffmann](https://github.com/clonker), 
[Christoph Fröhner](https://github.com/chrisfroe) and [Frank Noé](https://github.com/franknoe) 
of the Computational Molecular Biology group at the Freie Universität Berlin. This project continues
the [java software](https://github.com/readdy/readdy_java) of the same name, by
[Johannes Schöneberg](https://sites.google.com/a/schoeneberglab.org/johannes-schoeneberg/)
and Frank Noé.

ReaDDy v1.0.0 is released for Linux and Mac! See the [installation guide]({{site.baseurl}}/installation.html).

{% assign home_sections = site.home | sort: 'position' %}
{% for section in home_sections %}
<section id="{{ section.sectionName }}">
<h1>{{ section.title | remove: '<p>' | remove: '</p>'}}</h1>
{{ section.content | markdownify }}
</section>
{% endfor %}

