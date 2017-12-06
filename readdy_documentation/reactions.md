---
layout: page
title: Reactions
---

Reactions remove particles from, and add particles to the system. They typically have a microscopic/intrinsic rate $\lambda$.
This rate has units of inverse time and can be understood as the probability per unit time of the reaction occurring. Given an integration
step $\tau$ the probability of a reaction event is evaluated as $p = 1 - e^{-\lambda \tau}$.

Additionally `Fusion` and `Enzymatic` reactions can only occur when particles are closer than a certain distance $R$.

All reactions are added to the reaction registry, which is part of the `ReactionDiffusionSystem`
```python
system = readdy.ReactionDiffusionSystem()
system.reactions.add(...)
```

Each of the below listed reaction types can be registered in two ways: 
- Either with the generic `reactions.add(...)` method which accepts a descriptor string,
- or by calling `reactions.add_xxx(...)`, where `xxx` is to be replaced with one of `conversion`, `decay`, `fusion`, `fission`, or `enzymatic`.

{% assign sorted_reactions = site.reactions | sort: 'position' %}
{% for reaction in sorted_reactions %}
<section id="{{ reaction.sectionName }}">
<h1>{{ reaction.title | markdownify | remove: '<p>' | remove: '</p>'}}</h1>
{{ reaction.content | markdownify }}
</section>
{% endfor %}


