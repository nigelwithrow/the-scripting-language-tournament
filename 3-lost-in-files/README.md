@Tournament Participant

## Lost in files
> \- Hmm, I know some wizardry, I can open an SSH tunnel to that server - Nerd says after seeing the IP on a decoded poster.
> He starts to move his hands like crazy but out of nowhere blue sparks started appearing in front of him.
> Soon, the tunnel was ready. You couldn't see the end, but it was pulling you in...
> After you entered, you can feel that you are flying through and you can barely hear Nerd screaming behind:
> \- It was a tra...
> Suddenly, you feel the ground. Portal behind you instantly disappears and you take a look around.
> A regular linux install, nothing special. But something is just... Wrong. You need answers!

You are given a .tar.gz archive. It might contain text files, directories and other .tar.gz archives inside.
Your goal is to find a line that starts with an ascii string "Answer: " followed by some letters.
It is guaranteed to be no longer than 256 characters. Once you find it, print it.
Final test archive will be about 1GiB. Sample archive attached.

### Scoring
This challenge will be scored using the following formula:
```python
(min(5000 / runtime_ms, 1) + min(150 / token_count, 1) + elegance_score) / 3
```
