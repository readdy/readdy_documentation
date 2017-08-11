---
layout: page
title: Demonstration
---


<ul>
{% assign sorted_tutorials = site.tutorials | sort: 'position' %}
{% for tutorial in sorted_tutorials %}
{% if tutorial.category == 'demonstration' %}
<li>
<a href="{{ site.url }}{{ site.baseurl }}{{ tutorial.url }}">
{{ tutorial.title | markdownify | remove: '<p>' | remove: '</p>' }}
</a>
</li>
{% endif %}
{% endfor %}
</ul>