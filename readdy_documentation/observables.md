---
layout: page
title: Observables
---

Wanna observe something?

{% assign sorted_observables = site.observables | sort: 'position' %}
{% for observable in sorted_observables %}
<section id="{{ observable.sectionName }}">
<h1>{{ observable.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ observable.content | markdownify }}
</section>
{% endfor %}