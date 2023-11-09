import argparse
import csv
import time


def read_file(file_path):
    with open(file_path, 'r', encoding='utf-8', errors='surrogateescape') as file:
        file.readline()
        csv_reader = csv.reader(file)
        while True:
            for line in csv_reader:
                yield line
            file.seek(0)
            file.readline()


parser = argparse.ArgumentParser(description="Duplicate the contents of a source file to a target file.")
# Add source and target file arguments
parser.add_argument("source", help="Path to the source file")
parser.add_argument("blend_file", help="Path to the blend_file file")
parser.add_argument("target", help="Path to the target file")
parser.add_argument("--duplication_factor", help="Duplication factor", default=2, type=int)
# Parse the command-line arguments
args = parser.parse_args()
# Open the file and seek to the random line
st = time.time()
with open(args.source, 'r', encoding='utf-8', errors='surrogateescape') as source_file, \
        open(args.target, 'w', encoding='utf-8', errors='surrogateescape') as output_file:
    line_generator = read_file(args.blend_file)
    csv_reader = csv.reader(source_file)
    csv_writer = csv.writer(output_file)
    i = 0
    for line in csv_reader:
        csv_writer.writerow(line)
        if i > 0:
            for i in range(args.duplication_factor - 1):
                new_line = next(line_generator)
                # overwrite timestamp
                new_line[0] = line[0]
                csv_writer.writerow(new_line)
        i += 1
et = time.time()
print('Execution time:', et - st, 'seconds')
