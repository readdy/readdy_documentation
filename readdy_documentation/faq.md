---
layout: page
title: FAQ
---

Frequently asked questions

{% assign sorted_faqs = site.faq | sort: 'position' %}
{% for entry in sorted_faqs %}
<section id="{{ entry.sectionName }}">
<div class="entry-heading"><h2>{{ entry.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ entry.content | markdownify }}
</section>
{% endfor %}