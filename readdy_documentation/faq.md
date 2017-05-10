---
layout: page
title: FAQ
---

If you have an issue that is not covered here, just post it on our 
[issue tracker](https://github.com/readdy/readdy/issues) or [contact us](mailto:readdyadmin@lists.fu-berlin.de).

{% assign sorted_faqs = site.faq | sort: 'position' %}
{% for entry in sorted_faqs %}
<section id="{{ entry.sectionName }}">
<div class="entry-heading"><h2>{{ entry.title | markdownify | remove: '<p>' | remove: '</p>'}}</h2></div>
{{ entry.content | markdownify }}
</section>
{% endfor %}