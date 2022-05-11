#
# Copyright 2022 Erwan Mahe (github.com/erwanM974)
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from itertools import repeat

import random
import copy

from exp_commons import *

def make_multitrace(outer_loop_n):
    multi_trace = {}
    for key in sensor_example_lifelines:
        multi_trace[key] = []
    #
    while outer_loop_n > 0:
        multi_trace["CSI"] = multi_trace["CSI"] + ["CSI!ce"]
        multi_trace["CI"] = multi_trace["CI"] + ["CI?ce.CI!cmi"]
        multi_trace["SM"] = multi_trace["SM"] + ["SM?cmi.SM!rlsoc"]
        multi_trace["SOS"] = multi_trace["SOS"] + ["SOS?rlsoc.SOS!lsoc"]
        multi_trace["SM"] = multi_trace["SM"] + ["SM?lsoc"]
        # the par
        multi_trace["LSM"] = multi_trace["LSM"] + ["LSM?rbm.LSM!bm"]
        multi_trace["CSM"] = multi_trace["CSM"] + ["CSM?rcm.CSM!cm"]
        ## choices for interleaving
        interleav_1 = ["SM!rbm","SM?bm"]
        interleav_2 = ["SM!rcm","SM?cm"]
        interleaved = [x.pop(0) for x in random.sample([interleav_1]*len(interleav_1) + [interleav_2]*len(interleav_2), len(interleav_1)+len(interleav_2))]
        multi_trace["SM"] = multi_trace["SM"] + interleaved
        #
        multi_trace["SM"] = multi_trace["SM"] + ["SM!cm"]
        multi_trace["CSI"] = multi_trace["CSI"] + ["CSI?cm"]
        #
        inner_loop_n = random.randint(0,4)
        while inner_loop_n > 0:
            multi_trace["CA"] = multi_trace["CA"] + ["CA!tdc"]
            multi_trace["CR"] = multi_trace["CR"] + ["CR?tdc.CR!tmu"]
            multi_trace["CSM"] = multi_trace["CSM"] + ["CSM?tmu.CSM!ucm"]
            multi_trace["SM"] = multi_trace["SM"] + ["SM?ucm.SM!ucm"]
            multi_trace["CSI"] = multi_trace["CSI"] + ["CSI?ucm"]
            inner_loop_n -= 1
        outer_loop_n -= 1
    return multi_trace

def print_multi_trace(name,multi_trace):
    f = open("{}.htf".format(name), "w")
    f.truncate(0)  # empty file
    f.write("{\n")
    f.flush()
    for lf_name in sensor_example_lifelines:
        f.write("[{}] {}".format(lf_name, ".".join(multi_trace[lf_name])))
        if lf_name != sensor_example_lifelines[-1]:
            f.write(";\n")
        else:
            f.write("\n}\n")
        f.flush()

def multi_trace_length(mu):
    return sum( [len(x) for _,x in mu.items()] )

def cut_end_multi_trace(mu,goal_length):
    if multi_trace_length(mu) <= goal_length:
        return mu
    else:
        keys = [key for key,trace in mu.items() if len(trace) > 0]
        got_key = random.choice(keys)
        mu[got_key] = mu[got_key][:-1]
        return cut_end_multi_trace(mu,goal_length)

def add_err_at_end(mu):
    got_key = random.choice(sensor_example_lifelines)
    mu[got_key] += ["{}!err".format(got_key)]
    return mu

def generate_multi_trace_as_iterator():
    trace_id = 1
    for outer_loop_n in multitrace_outer_loop_ns:
        for _ in repeat(None,multi_trace_number_per_loop_height):
            mu = make_multitrace(outer_loop_n)
            orig_length = multi_trace_length(mu)
            for obs in multi_trace_obs:
                goal_length = int(orig_length * (obs / 100))
                got_mu = cut_end_multi_trace(copy.deepcopy(mu), goal_length)
                yield (got_mu, trace_id, outer_loop_n, orig_length, goal_length, obs, True)
                fail_mu = add_err_at_end(got_mu)
                yield (fail_mu, trace_id, outer_loop_n, orig_length, goal_length + 1, obs, False)
            trace_id = trace_id + 1

