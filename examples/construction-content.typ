#import "../template/content.typ": article as clause, commentary as explain

= 总则 <general>

#clause[为规定基本要求和技术措施，制定本规范。] <purpose>
#explain[本条说明规范制定的目的。说明紧跟正文编写，在文后自动汇编。]

#clause[本规范适用于工程的建设和使用维护。] <scope>
#explain[本条界定适用范围；可引用正文条款 @purpose。]

= 基本规定
== 功能要求

#clause[
应保障人员安全，并满足使用功能。

+ 保障通行安全；
+ 满足使用空间需求；
+ 方便日常维护。
] <safety>
#explain[本条提出安全和功能的基本目标要求。]

#clause[应提供便捷、连续的通行路径。] <access>
#explain[本条说明通行的连续性。]

#clause[设备设施应方便检查和维护。] <maintenance>
#explain(of: <access>, through: <maintenance>)[两条合并说明，条号取自正文，不需手填。]
