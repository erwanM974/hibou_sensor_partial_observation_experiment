

from exp_generate import generate_multi_trace_as_iterator,print_multi_trace
from exp_perfs import get_hibou_time
from exp_commons import *


def experiment(csv_name):
    f = open("{}.csv".format(csv_name), "w")
    f.truncate(0)  # empty file
    f.write("id,outer_loop_n,orig_length,length,obs,isPass,technique,time\n")
    f.flush()
    #
    for (got_mu, trace_id, outer_loop_n, orig_length, length, obs, isPass) in generate_multi_trace_as_iterator():
        print_multi_trace("temp",got_mu)
        for hsf in hsfs:
            got_time = get_hibou_time(hsf, "temp", 5, isPass)
            line = "{},{},{},{},{},{},{}".format(trace_id,outer_loop_n, orig_length, length, obs, isPass, hsf)
            if got_time != None:
                line += ",{}".format(got_time)
            else:
                line += ",NA"
            f.write("{}\n".format(line))
            f.flush()

if __name__ == "__main__":
    experiment("senmed")

