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


from subprocess import STDOUT, check_output, TimeoutExpired
import time
import statistics

from exp_commons import *



def get_hibou_time(hsf, htf, num_tries, isPass):
    hsf_file = "./{}.hsf".format(hsf)
    htf_file = "./{}.htf".format(htf)
    #
    outwrap = None
    tries = []
    while len(tries) < num_tries:
        t_start = time.time()
        try:
            outwrap = check_output(["./hibou_label.exe", "analyze", hsf_file, htf_file], stderr=STDOUT, timeout=timeout_in_seconds)
            tries.append(time.time() - t_start)
        except TimeoutExpired:
            return None
    t_total = statistics.median(tries)
    #
    outwrap = str(outwrap)
    if "Pass" in outwrap:
        if isPass:
            return t_total
        else:
            raise Exception("Pass but expected Fail")
    elif "Fail" in outwrap:
        if isPass:
            raise Exception("Fail but expected Pass")
        else:
            return t_total
    elif "Inconc" in outwrap:
        raise Exception("Inconc ?")
    else:
        print(outwrap)
        raise Exception("Unknown")

