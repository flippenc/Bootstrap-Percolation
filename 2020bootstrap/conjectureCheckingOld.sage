load("gt.sage")
load('conjecturing.py')
load("bootstrap_definitions.sage")

from sympy import *
import re

dictionary = {'is_2_bootstrap_good': is_2_bootstrap_good,
              'is_dirac': is_dirac,
              'is_ore': is_ore,
              'is_two_connected': is_two_connected,
              'is_three_connected': is_three_connected,
              'has_radius_equal_diameter': has_radius_equal_diameter,
              'is_cubic': is_cubic,
              'diameter_equals_twice_radius': diameter_equals_twice_radius,
              'is_locally_connected': is_locally_connected,
              'is_locally_dirac': is_locally_dirac,
              'is_locally_bipartite': is_locally_bipartite,
              'has_paw': has_paw,
              'has_p4': has_p4,
              'is_p4_free': is_p4_free,
              'is_dart_free': is_dart_free,
              'has_kite': has_kite,
              'is_kite_free': is_kite_free,
              'has_H': has_H,
              'is_H_free': is_H_free,
              'order_leq_twice_max_degree': order_leq_twice_max_degree,
              'has_twin': has_twin,
              'is_twin_free': is_twin_free,
              'diameter_equals_two': diameter_equals_two,
              'girth_greater_than_2log': girth_greater_than_2log,
              'pairs_have_unique_common_neighbor': pairs_have_unique_common_neighbor,
              'has_star_center': has_star_center,
              'has_c4': has_c4,
              'is_c4_free': is_c4_free,
              'is_subcubic': is_subcubic,
              'is_quasi_regular': is_quasi_regular,
              'is_bad': is_bad,
              'has_k4': has_k4,
              'is_k4_free': is_k4_free,
              'is_locally_unicyclic': is_locally_unicyclic,
              'has_simplical_vertex': has_simplical_vertex,
              'is_locally_planar': is_locally_planar,
              'is_four_connected': is_four_connected,
              'is_claw_free_paw_free': is_claw_free_paw_free,
              'has_bull': has_bull,
              'is_bull_free': is_bull_free,
              'is_claw_free_bull_free': is_claw_free_bull_free,
              'has_F': has_F,
              'is_oberly_sumner': is_oberly_sumner,
              'is_oberly_sumner_bull': is_oberly_sumner_bull,
              'is_oberly_sumner_p4': is_oberly_sumner_p4,
              'is_matthews_sumner': is_matthews_sumner,
              'chvatals_condition': chvatals_condition,
              'is_matching': is_matching,
              'is_local_matching': is_local_matching,
              'has_odd_order': has_odd_order,
              'has_even_order': has_even_order,
              'is_double_clique': is_double_clique,
              'is_fork_free': is_fork_free}

propertyStrings = ["is_regular",
                   "is_planar",
                   "is_eulerian",
                   "is_clique",
                   "is_circular_planar",
                   "is_chordal",
                   "is_bipartite",
                   "is_cartesian_product",
                   "is_even_hole_free",
                   "is_gallai_tree",
                   "is_line_graph",
                   "is_overfull",
                   "is_perfect",
                   "is_split",
                   "is_strongly_regular",
                   "is_triangle_free",
                   "is_weakly_chordal",
                   "is_dirac",
                   "is_ore",
                   "is_two_connected",
                   "is_three_connected",
                   "has_perfect_matching",
                   "has_radius_equal_diameter",
                   "is_cubic",
                   "diameter_equals_twice_radius",
                   "is_locally_connected",
                   "is_locally_dirac",
                   "is_locally_bipartite",
                   "has_paw",
                   "has_p4",
                   "is_p4_free",
                   "is_dart_free",
                   "has_kite",
                   "is_kite_free",
                   "has_H",
                   "is_H_free",
                   "order_leq_twice_max_degree",
                   "has_twin",
                   "is_twin_free",
                   "diameter_equals_two",
                   "girth_greater_than_2log",
                   "is_cycle",
                   "pairs_have_unique_common_neighbor",
                   "has_star_center",
                   "has_c4",
                   "is_c4_free",
                   "is_subcubic",
                   "is_quasi_regular",
                   "is_bad",
                   "has_k4",
                   "is_k4_free",
                   "is_locally_unicyclic",
                   "has_simplical_vertex",
                   "is_locally_planar",
                   "is_four_connected",
                   "is_claw_free_paw_free",
                   "has_bull",
                   "is_bull_free",
                   "is_claw_free_bull_free",
                   "has_F",
                   "is_oberly_sumner",
                   "is_oberly_sumner_bull",
                   "is_oberly_sumner_p4",
                   "is_matthews_sumner",
                   "chvatals_condition",
                   "is_matching",
                   "is_local_matching",
                   "has_odd_order",
                   "has_even_order",
                   "is_circulant",
                   "is_block_graph",
                   "is_cactus",
                   "is_cograph",
                   "is_long_hole_free",
                   "is_polyhedral",
                   "is_prime",
                   "is_self_complementary",
                   "is_double_clique",
                   "is_fork_free"]

allOfTheConjectures = ["(((is_planar)^(has_radius_equal_diameter))^(is_bull_free))->(is_2_bootstrap_good)",
"((is_claw_free_paw_free)^(is_chordal))->(is_2_bootstrap_good)",
"(((is_line_graph)^(has_radius_equal_diameter))&(has_paw))->(is_2_bootstrap_good)",
"(is_dirac)->(is_2_bootstrap_good)",
"(is_ore)->(is_2_bootstrap_good)",
"(is_locally_connected)->(is_2_bootstrap_good)",
"(is_locally_dirac)->(is_2_bootstrap_good)",
"(~(has_p4))->(is_2_bootstrap_good)",
"(is_p4_free)->(is_2_bootstrap_good)",
"(((is_oberly_sumner)|(has_H))^(~(is_perfect)))->(is_2_bootstrap_good)",
"(has_star_center)->(is_2_bootstrap_good)",
"(((has_paw)&(has_c4))&(is_H_free))->(is_2_bootstrap_good)",
"((~(is_prime))&(is_c4_free))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(is_subcubic))->(is_2_bootstrap_good)",
"(is_bad)->(is_2_bootstrap_good)",
"(is_oberly_sumner_bull)->(is_2_bootstrap_good)",
"(is_oberly_sumner_p4)->(is_2_bootstrap_good)",
"(is_matthews_sumner)->(is_2_bootstrap_good)",
"(chvatals_condition)->(is_2_bootstrap_good)",
"(is_cograph)->(is_2_bootstrap_good)",
"(((is_cactus)|(has_simplical_vertex))^(~(is_regular)))->(is_2_bootstrap_good)",
"((is_three_connected)^(is_regular))->(is_2_bootstrap_good)",
"((is_perfect)^(is_bipartite))->(is_2_bootstrap_good)",
"((~(is_bipartite))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"(((is_self_complementary)^(is_long_hole_free))&(is_even_hole_free))->(is_2_bootstrap_good)",
"((~(is_prime))&(is_even_hole_free))->(is_2_bootstrap_good)",
"((is_perfect)^(is_bipartite))->(is_2_bootstrap_good)",
"(((is_oberly_sumner)|(has_H))^(~(is_perfect)))->(is_2_bootstrap_good)",
"((diameter_equals_two)^(is_strongly_regular))->(is_2_bootstrap_good)",
"((is_strongly_regular)^(diameter_equals_two))->(is_2_bootstrap_good)",
"((is_weakly_chordal)^(is_long_hole_free))->(is_2_bootstrap_good)",
"((is_weakly_chordal)&(is_four_connected))->(is_2_bootstrap_good)",
"((~(has_perfect_matching))&(has_kite))->(is_2_bootstrap_good)",
"(~((has_perfect_matching)|(is_dart_free)))->(is_2_bootstrap_good)",
"((is_claw_free_bull_free)^(is_claw_free_paw_free))->(is_2_bootstrap_good)",
"((is_self_complementary)^(is_claw_free_bull_free))->(is_2_bootstrap_good)",
"((is_local_matching)^(is_oberly_sumner))->(is_2_bootstrap_good)",
"(((has_radius_equal_diameter)&(has_paw))^(is_local_matching))->(is_2_bootstrap_good)",
"((is_claw_free_paw_free)^(is_block_graph))->(is_2_bootstrap_good)",
"((diameter_equals_two)&(is_block_graph))->(is_2_bootstrap_good)",
"(((is_cactus)|(has_simplical_vertex))^(~(is_regular)))->(is_2_bootstrap_good)",
"((is_cactus)&(has_paw))->(is_2_bootstrap_good)",
"(((is_bull_free)^(has_radius_equal_diameter))^(is_circular_planar))->(is_2_bootstrap_good)",
"((~(is_circular_planar))&(is_double_clique))->(is_2_bootstrap_good)",
"((~(is_circular_planar))&(is_fork_free))->(is_2_bootstrap_good)",
"((is_gallai_tree)^(is_self_complementary))->(is_2_bootstrap_good)",
"((is_double_clique)^(is_gallai_tree))->(is_2_bootstrap_good)",
"((is_self_complementary)^(is_gallai_tree))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(is_quasi_regular))->(is_2_bootstrap_good)",
"((~(is_quasi_regular))&(is_double_clique))->(is_2_bootstrap_good)",
"((~(is_quasi_regular))&(diameter_equals_two))->(is_2_bootstrap_good)",
"(((is_oberly_sumner)|(has_H))^(~(is_perfect)))->(is_2_bootstrap_good)",
"((is_local_matching)^(is_oberly_sumner))->(is_2_bootstrap_good)",
"((is_double_clique)&(is_oberly_sumner))->(is_2_bootstrap_good)",
"(((is_fork_free)&(has_odd_order))&(has_bull))->(is_2_bootstrap_good)",
"((is_four_connected)&(is_fork_free))->(is_2_bootstrap_good)",
"((~(is_circular_planar))&(is_fork_free))->(is_2_bootstrap_good)",
"((is_two_connected)&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((~(is_k4_free))&(is_two_connected))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(is_two_connected))->(is_2_bootstrap_good)",
"((is_two_connected)&(has_kite))->(is_2_bootstrap_good)",
"((~(is_kite_free))&(has_odd_order))->(is_2_bootstrap_good)",
"(~((has_simplical_vertex)|(is_kite_free)))->(is_2_bootstrap_good)",
"(~((has_even_order)|(is_kite_free)))->(is_2_bootstrap_good)",
"((~(is_kite_free))&(diameter_equals_two))->(is_2_bootstrap_good)",
"(((is_three_connected)->(is_H_free))^(~(diameter_equals_two)))->(is_2_bootstrap_good)",
"((has_k4)&(is_H_free))->(is_2_bootstrap_good)",
"((diameter_equals_two)&(is_H_free))->(is_2_bootstrap_good)",
"(((has_paw)&(has_c4))&(is_H_free))->(is_2_bootstrap_good)",
"(~(is_k4_free))->(is_2_bootstrap_good)",
"((is_k4_free)^(is_locally_bipartite))->(is_2_bootstrap_good)",
"((is_locally_bipartite)^(is_k4_free))->(is_2_bootstrap_good)",
"((~(is_k4_free))&(is_two_connected))->(is_2_bootstrap_good)",
"((is_claw_free_paw_free)^(is_chordal))->(is_2_bootstrap_good)",
"((is_claw_free_bull_free)^(is_claw_free_paw_free))->(is_2_bootstrap_good)",
"((is_claw_free_paw_free)^(is_block_graph))->(is_2_bootstrap_good)",
"((is_claw_free_paw_free)^(is_double_clique))->(is_2_bootstrap_good)",
"((has_bull)&(is_long_hole_free))->(is_2_bootstrap_good)",
"(((is_self_complementary)^(is_long_hole_free))&(is_even_hole_free))->(is_2_bootstrap_good)",
"((is_weakly_chordal)^(is_long_hole_free))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)^(is_long_hole_free))->(is_2_bootstrap_good)",
"((~(is_prime))&(is_c4_free))->(is_2_bootstrap_good)",
"((~(is_prime))&(is_even_hole_free))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(is_prime))->(is_2_bootstrap_good)",
"(((is_prime)^(has_paw))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(is_subcubic))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(is_quasi_regular))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(is_three_connected))->(is_2_bootstrap_good)",
"((~(has_bull))^(is_triangle_free))->(is_2_bootstrap_good)",
"(~((is_dart_free)|(has_even_order)))->(is_2_bootstrap_good)",
"(~((has_even_order)|(is_kite_free)))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(has_even_order))->(is_2_bootstrap_good)",
"(((order_leq_twice_max_degree)^(is_self_complementary))&(has_even_order))->(is_2_bootstrap_good)",
"(((has_radius_equal_diameter)^(has_even_order))&(~(has_simplical_vertex)))->(is_2_bootstrap_good)",
"(~(is_locally_bipartite))->(is_2_bootstrap_good)",
"((~(has_k4))^(is_locally_bipartite))->(is_2_bootstrap_good)",
"((is_k4_free)^(is_locally_bipartite))->(is_2_bootstrap_good)",
"((~(is_locally_bipartite))&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((is_locally_bipartite)^(is_k4_free))->(is_2_bootstrap_good)",
"(~((has_F)|(is_locally_bipartite)))->(is_2_bootstrap_good)",
"(((is_bull_free)^(has_radius_equal_diameter))^(is_circular_planar))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(diameter_equals_two))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(is_three_connected))->(is_2_bootstrap_good)",
"(((is_planar)^(has_radius_equal_diameter))^(is_bull_free))->(is_2_bootstrap_good)",
"((has_kite)&(has_odd_order))->(is_2_bootstrap_good)",
"(((is_fork_free)&(has_odd_order))&(has_bull))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(has_odd_order))->(is_2_bootstrap_good)",
"((~(is_kite_free))&(has_odd_order))->(is_2_bootstrap_good)",
"((has_odd_order)&(has_kite))->(is_2_bootstrap_good)",
"((~(has_odd_order))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"(((is_self_complementary)^(is_long_hole_free))&(is_even_hole_free))->(is_2_bootstrap_good)",
"((is_gallai_tree)^(is_self_complementary))->(is_2_bootstrap_good)",
"((is_self_complementary)^(is_claw_free_bull_free))->(is_2_bootstrap_good)",
"(((order_leq_twice_max_degree)^(is_self_complementary))&(has_even_order))->(is_2_bootstrap_good)",
"((is_self_complementary)^(is_double_clique))->(is_2_bootstrap_good)",
"((is_self_complementary)^(is_gallai_tree))->(is_2_bootstrap_good)",
"(has_k4)->(is_2_bootstrap_good)",
"((has_k4)&(is_four_connected))->(is_2_bootstrap_good)",
"((has_k4)&(is_H_free))->(is_2_bootstrap_good)",
"((has_radius_equal_diameter)&(has_k4))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_k4))->(is_2_bootstrap_good)",
"((~(has_k4))^(is_locally_bipartite))->(is_2_bootstrap_good)",
"((~(has_bull))&(has_k4))->(is_2_bootstrap_good)",
"((has_kite)&(is_four_connected))->(is_2_bootstrap_good)",
"((has_k4)&(is_four_connected))->(is_2_bootstrap_good)",
"((has_bull)&(is_four_connected))->(is_2_bootstrap_good)",
"((is_weakly_chordal)&(is_four_connected))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(is_four_connected))->(is_2_bootstrap_good)",
"((is_four_connected)&(is_fork_free))->(is_2_bootstrap_good)",
"((is_four_connected)&(has_paw))->(is_2_bootstrap_good)",
"((has_F)&(is_three_connected))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(has_F))->(is_2_bootstrap_good)",
"((has_F)&(has_radius_equal_diameter))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(has_F))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_F))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_F))->(is_2_bootstrap_good)",
"(~((has_F)|(is_locally_bipartite)))->(is_2_bootstrap_good)",
"((is_double_clique)^(is_gallai_tree))->(is_2_bootstrap_good)",
"((~(is_circular_planar))&(is_double_clique))->(is_2_bootstrap_good)",
"((is_claw_free_paw_free)^(is_double_clique))->(is_2_bootstrap_good)",
"((is_double_clique)&(is_oberly_sumner))->(is_2_bootstrap_good)",
"((~(is_quasi_regular))&(is_double_clique))->(is_2_bootstrap_good)",
"((is_self_complementary)^(is_double_clique))->(is_2_bootstrap_good)",
"((is_double_clique)&(has_paw))->(is_2_bootstrap_good)",
"(((is_bull_free)^(has_radius_equal_diameter))^(is_circular_planar))->(is_2_bootstrap_good)",
"(((is_line_graph)^(has_radius_equal_diameter))&(has_paw))->(is_2_bootstrap_good)",
"((has_F)&(has_radius_equal_diameter))->(is_2_bootstrap_good)",
"((has_kite)&(has_radius_equal_diameter))->(is_2_bootstrap_good)",
"((has_radius_equal_diameter)&(has_k4))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(has_radius_equal_diameter))->(is_2_bootstrap_good)",
"(((has_radius_equal_diameter)^(has_even_order))&(~(has_simplical_vertex)))->(is_2_bootstrap_good)",
"(((has_radius_equal_diameter)&(has_paw))^(is_local_matching))->(is_2_bootstrap_good)",
"(((is_planar)^(has_radius_equal_diameter))^(is_bull_free))->(is_2_bootstrap_good)",
"(~((is_dart_free)|(has_even_order)))->(is_2_bootstrap_good)",
"(~((is_dart_free)|(has_simplical_vertex)))->(is_2_bootstrap_good)",
"(~((has_perfect_matching)|(is_dart_free)))->(is_2_bootstrap_good)",
"(~((has_simplical_vertex)|(is_dart_free)))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(has_odd_order))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(is_four_connected))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(has_radius_equal_diameter))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(is_two_connected))->(is_2_bootstrap_good)",
"((has_kite)&(has_odd_order))->(is_2_bootstrap_good)",
"((has_kite)&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((~(has_perfect_matching))&(has_kite))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_kite))->(is_2_bootstrap_good)",
"((has_kite)&(is_four_connected))->(is_2_bootstrap_good)",
"((has_odd_order)&(has_kite))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_kite))->(is_2_bootstrap_good)",
"((has_kite)&(has_radius_equal_diameter))->(is_2_bootstrap_good)",
"((has_kite)&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((is_two_connected)&(has_kite))->(is_2_bootstrap_good)",
"((diameter_equals_two)^(is_strongly_regular))->(is_2_bootstrap_good)",
"(((is_three_connected)->(is_H_free))^(~(diameter_equals_two)))->(is_2_bootstrap_good)",
"((~(is_kite_free))&(diameter_equals_two))->(is_2_bootstrap_good)",
"((diameter_equals_two)&(is_block_graph))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(diameter_equals_two))->(is_2_bootstrap_good)",
"((diameter_equals_two)&(is_H_free))->(is_2_bootstrap_good)",
"((has_bull)&(diameter_equals_two))->(is_2_bootstrap_good)",
"((diameter_equals_two)&(has_bull))->(is_2_bootstrap_good)",
"((~(is_quasi_regular))&(diameter_equals_two))->(is_2_bootstrap_good)",
"((is_strongly_regular)^(diameter_equals_two))->(is_2_bootstrap_good)",
"(((is_line_graph)^(has_radius_equal_diameter))&(has_paw))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(has_paw))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_paw))->(is_2_bootstrap_good)",
"((is_four_connected)&(has_paw))->(is_2_bootstrap_good)",
"((has_paw)&(is_three_connected))->(is_2_bootstrap_good)",
"((is_double_clique)&(has_paw))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_paw))->(is_2_bootstrap_good)",
"(((is_prime)^(has_paw))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((is_cactus)&(has_paw))->(is_2_bootstrap_good)",
"(((has_radius_equal_diameter)&(has_paw))^(is_local_matching))->(is_2_bootstrap_good)",
"(((has_paw)&(has_c4))&(is_H_free))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(is_three_connected))->(is_2_bootstrap_good)",
"((has_kite)&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(has_F))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)^(is_long_hole_free))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(has_paw))->(is_2_bootstrap_good)",
"((~(is_locally_bipartite))&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(has_bull))->(is_2_bootstrap_good)",
"(((order_leq_twice_max_degree)^(is_self_complementary))&(has_even_order))->(is_2_bootstrap_good)",
"((is_two_connected)&(order_leq_twice_max_degree))->(is_2_bootstrap_good)",
"(~((is_dart_free)|(has_simplical_vertex)))->(is_2_bootstrap_good)",
"(~((has_simplical_vertex)|(is_dart_free)))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_kite))->(is_2_bootstrap_good)",
"(~((has_simplical_vertex)|(is_kite_free)))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_F))->(is_2_bootstrap_good)",
"(((is_cactus)|(has_simplical_vertex))^(~(is_regular)))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_bull))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_k4))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_paw))->(is_2_bootstrap_good)",
"((has_simplical_vertex)&(is_three_connected))->(is_2_bootstrap_good)",
"(((has_radius_equal_diameter)^(has_even_order))&(~(has_simplical_vertex)))->(is_2_bootstrap_good)",
"((~(is_dart_free))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((has_bull)&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(is_prime))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(has_F))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(has_even_order))->(is_2_bootstrap_good)",
"((~(is_bipartite))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(has_bull))->(is_2_bootstrap_good)",
"((has_kite)&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((~(has_odd_order))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"(((is_prime)^(has_paw))&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"(((is_three_connected)->(is_H_free))^(~(diameter_equals_two)))->(is_2_bootstrap_good)",
"((has_F)&(is_three_connected))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(is_three_connected))->(is_2_bootstrap_good)",
"((has_bull)&(is_three_connected))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_bull))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_kite))->(is_2_bootstrap_good)",
"((~(is_bull_free))&(is_three_connected))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_F))->(is_2_bootstrap_good)",
"((has_simplical_vertex)&(is_three_connected))->(is_2_bootstrap_good)",
"((has_paw)&(is_three_connected))->(is_2_bootstrap_good)",
"((~(is_triangle_free))&(is_three_connected))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_paw))->(is_2_bootstrap_good)",
"((is_three_connected)^(is_regular))->(is_2_bootstrap_good)",
"((has_bull)&(is_long_hole_free))->(is_2_bootstrap_good)",
"(((is_fork_free)&(has_odd_order))&(has_bull))->(is_2_bootstrap_good)",
"((has_bull)&(is_three_connected))->(is_2_bootstrap_good)",
"((has_bull)&(diameter_equals_twice_radius))->(is_2_bootstrap_good)",
"((is_three_connected)&(has_bull))->(is_2_bootstrap_good)",
"((has_bull)&(is_four_connected))->(is_2_bootstrap_good)",
"((~(has_simplical_vertex))&(has_bull))->(is_2_bootstrap_good)",
"((~(has_bull))&(has_k4))->(is_2_bootstrap_good)",
"((has_bull)&(diameter_equals_two))->(is_2_bootstrap_good)",
"((diameter_equals_twice_radius)&(has_bull))->(is_2_bootstrap_good)",
"((diameter_equals_two)&(has_bull))->(is_2_bootstrap_good)",
"((order_leq_twice_max_degree)&(has_bull))->(is_2_bootstrap_good)",
"((~(has_bull))^(is_triangle_free))->(is_2_bootstrap_good)"]

#Using sympy for evaluating logical expressions:
#https://docs.sympy.org/latest/modules/logic.html#simplification-and-equivalence-testing

sym = []
sym += symbols(propertyStrings)

#for c in a:
#    print "Property: "
#    print c

#a bunch of random conjectures for testing this code:
testConjectures = ["(((diameter_equals_two)&(is_even_hole_free))&(has_perfect_matching))->(is_2_bootstrap_good)",
                   "(((diameter_equals_two)&(order_leq_twice_max_degree))&(~(is_planar)))->(is_2_bootstrap_good)",
                   "(((diameter_equals_two)&(order_leq_twice_max_degree))&(has_bull))->(is_2_bootstrap_good)",
                   "(((diameter_equals_two)&(is_eulerian))&(~(is_even_hole_free)))->(is_2_bootstrap_good)",
                   "(((diameter_equals_two)&(is_even_hole_free))&(has_perfect_matching))->(is_2_bootstrap_good)",
                   "(((diameter_equals_two)&(has_c4))&(is_oberly_sumner))->(is_2_bootstrap_good)"]

fixedConjectures = []
#SymPy uses >> as implies instead of ->
for i in range(1,len(testConjectures)):
    b = testConjectures[i]
    #print b.replace("->",">>")
    fixedConjectures.append(b.replace("->",">>"))

#for c in fixedConjectures:
#    print c

#print(fixedConjectures[3])

#sympy doesn't like a ^ b notation for XOR, need to replace it with Xor(a,b)
#https://stackoverflow.com/questions/7124778/how-to-match-anything-up-until-this-sequence-of-characters-in-a-regular-expres#7124976
#We will use regex to fix this:
#https://regex101.com/r/6gWcZ3/2

#Goal with this regex:
#group() - fullstring - (property1^property2)
#group(1) - property1
#group(3)- property2
#want to replace fullstring with Xor(property1, property2) to make sympy happy

regex = r"\(([^)([^)]+)\)+(\^)+\(([^)]+)\)"

#run this in a loop to fix all cases of XOR in the string
matches = re.search(regex, fixedConjectures[3])
if matches:
    print "string to replace : ", matches.group()
    print "property1 : ", matches.group(1)
    print "property2 : ", matches.group(3)
    replaceString = "Xor(%s,%s)" % (matches.group(1),matches.group(3))
    #print(fixedConjectures[3].replace(matches.group(),replaceString))

DNFConj = str(to_dnf(fixedConjectures[3].replace(matches.group(),replaceString)))
print "DNFConj is: %s" % DNFConj

#now that the conjecture is in DNF, we can evaluate it more easily by checking each OR condition and replacing them with TRUE or FALSE
#ex:  if (is_2_bootstrap_good(g))
#        replace is_2_bootstrap_good with TRUE
#     else
#        replace is_2_bootstrap_good with FALSE

# if ANY of the OR conditions is true -> return and this graph has failed to prove the conjecture false
# if ALL of the OR conditions are false -> return and the conjecture is definitely false

# loop this process for every graph that we want to check the conjecture against

# to check the DNF properties:
#     pull the property names out of the string and check if they are names of functions
#     properties are either: "Graph." properties which are methods (g.is_eulerian, etc.) or they are custom properties from gt.sage which are functions (is_ore(g), etc.)
#     first, try to call the property as if it is a "Graph." property, if it returns an error, it is not a "Graph." property and we must check the dictionary

# Referenced for figuring out how to do this:
#     https://docs.python.org/3/tutorial/datastructures.html#dictionaries
#     https://stackoverflow.com/questions/9205081/is-there-a-way-to-store-a-function-in-a-list-or-dictionary-so-that-when-the-inde/9205091#9205091
#     https://stackoverflow.com/a/7581689

#Make another regex or use string functions to split up the DNF string into its individual properties:
#https://regex101.com/r/YDwzVa/2

#Goal with this regex:
#we need to get the individual properties out of these groups, we also need to remove extra parentheses so that the string exactly matches a dictionary entry
#group(1) of each iterative match of the string is a boolean statement:
#Ex: is_2_bootstrap_good | ~diameter_equals_two | (has_simplical_vertex & is_block_graph) | (has_simplical_vertex & ~has_simplical_vertex) | (is_block_graph & ~is_block_graph) | (~has_simplical_vertex & ~is_block_graph)
# Gives matches: is_2_bootstrap_good,
#                diameter_equals_two,
#                has_simplical_vertex,
#                is_block_graph,
#                has_simplical_vertex,
#                has_simplical_vertex,
#                is_block_graph,
#                is_block_graph,
#                has_simplical_vertex,
#                is_block_graph
# we won't actually have to check all of these properties since there are repeated instances, but this will allow us to parse through the string very easily
# https://stackoverflow.com/questions/5060659/regexes-how-to-access-multiple-matches-of-a-group

# dictionaryTestGraph = graphs.CompleteGraph(5)
# dictionaryTestGraph2 = graphs.PetersenGraph()
# testString = "is_ore"
# testString2 = "is_bipartite"
# testString3 = "some_fake_method"
# testString4 = "Graph.is_bipartite"
# we have to remove the "Graph." prefix if it is a "Graph." property
# checkIfMethod = 1
# if "Graph." in testString4:
#     testString4 = testString4.replace("Graph.","")
#     try:
#         getattr(dictionaryTestGraph2, testString4)()
#         checkIfMethod = 2
#     except AttributeError:
#       this method is not a "Graph." property, let's check the dictionary
#       print "This method does not exist"
#         checkIfMethod = 0
# if checkIfMethod != 2:
#     try:
#         dictionary[testString4](dictionaryTestGraph2)
#     except AttributeError:
#         print "This string is neither a recognized method nor a recognized function, something is wrong"

#print dictionary[testString](dictionaryTestGraph)
#print getattr(dictionaryTestGraph2, testString2)()

testGraph = graphs.CompleteGraph(5)
testGraph2 = graphs.PetersenGraph()
print DNFConj
regex2 = r"\|*([^|\(\s\)&~]+)\|*"
matches2 = re.findall(regex2, DNFConj)
if matches2:
    print matches2
else:
    print "No matches found"

ConjCheck = ""
checkIfMethod = -1
checkResult = -1
for i in range(0,len(matches2)):
    checkIfMethod = 1
    print matches2[i]
    ConjCheck = matches2[i]
    if checkIfMethod == 1: #"Graph." in ConjCheck:
        #ConjCheck = ConjCheck.replace("Graph.","")
        try:
            checkResult = getattr(testGraph, ConjCheck)()
            print "checkResult is %s" %checkResult
            checkIfMethod = 2
        except AttributeError:
            #this method is not a "Graph." property, let's check the dictionary
            checkIfMethod = 0
    if checkIfMethod != 2:
        try:
            checkResult = dictionary[ConjCheck](testGraph)
            #print "checkResult is %s" %checkResult
        except AttributeError:
            print "This string is neither a recognized method nor a recognized function, something is wrong"
    DNFConj = DNFConj.replace(matches2[i],str(checkResult))
    print DNFConj
    resultBool = str(simplify_logic(DNFConj))
    if ( resultBool == "True" or resultBool == "False"):
        print "This conjecture is %s for Graph %s" %(resultBool, testGraph.graph6_string())
        break

def checkConjecture(conj, graphs):
    originalConj = conj
    sym = []
    sym += symbols(propertyStrings)

    if "->" in conj:
        conj = conj.replace("->",">>")
    #print(conj)

    toDNFRegex = r"\(([^)([^)]+)\)+(\^)+\(([^)]+)\)"

    toDNFMatches = re.search(toDNFRegex, conj)
    if toDNFMatches:
        replaceString = "Xor(%s,%s)" % (toDNFMatches.group(1), toDNFMatches.group(3))
        conj = conj.replace(toDNFMatches.group(),replaceString)
    #print(conj)
    try:
        conj = str(to_dnf(conj))
    except SympifyError:
        print "Error with conjecture %s" %(conj)
        return

    getDNFPropRegex = r"\|*([^|\(\s\)&~]+)\|*"

    neverFalse = 0
    getDNFPropMatches = re.findall(getDNFPropRegex, conj)
    #print(getDNFPropMatches)

    for i in range(0,len(graphs)):
        checkAgainstGraph = graphs[i]
        for j in range(0, len(getDNFPropMatches)):
            checkIfMethod = 1
            propertyToCheck = getDNFPropMatches[j]

            if checkIfMethod == 1:
                try:
                    checkResult = getattr(checkAgainstGraph, propertyToCheck)()
                    checkIfMethod = 2
                except AttributeError:
                    checkIfMethod = 0

            if checkIfMethod != 2:
                #print("Got here")
                try:
                    checkResult = dictionary[propertyToCheck](checkAgainstGraph)
                except AttributeError:
                    print "This string, %s is neither a recognized method nor a recognized function, something is wrong" %(propertyToCheck)
            #print(conj)
            conj = conj.replace(getDNFPropMatches[j], str(checkResult))
            #print(conj)

            try:
                conjCopy = str(conj)
                #print(str(conj))
                try:
                    resultBool = str(simplify_logic(conj))
                    #print("ResultBool is %s" %resultBool)
                    if (resultBool == -1 or resultBool == 1):
                        if (resultBool == -1):
                            neverFalse = -1
                            print "Conjecture: %s is false for Graph %s" %(originalConj, checkAgainstGraph.graph6_string())
                            return
                        #print "Conjecture: %s is %s for Graph %s" %(originalConj, resultBool, checkAgainstGraph.graph6_string())
                        break
                except AttributeError:
                    resultBool = eval(stringSimplify(conjCopy))
                    if (resultBool == False):
                        neverFalse = -1
                    #print "Conjecture: %s is %s for Graph %s" %(originalConj, resultBool, checkAgainstGraph.graph6_string())
                    break
            except TypeError:
                continue
    if(neverFalse == 0):
        print("%s was true for all tested graphs" %(originalConj))
    #else:
    #    print("This conjecture is false")


def stringSimplify(conj):
    conj = conj.replace("&", "and ")
    conj = conj.replace("|", "or ")
    conj = conj.replace("~", "not ")
    #print conj
    return conj