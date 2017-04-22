---
layout: page
title: Observables
---

Wanna observe something?

{% assign sorted_observables = site.observables | sort: 'position' %}
{% for observable in sorted_observables %}
<section id="{{ observable.sectionName }}">
<div class="entry-heading"><h2>{{ observable.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ observable.content | markdownify }}
</section>
{% endfor %}